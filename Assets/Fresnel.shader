Shader "Unlit/Fresnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _val("val",Range(0,1))=0
        _FresnelColor("FresnelColor",Color)=(0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _FresnelColor;
            float _val;

            v2f vert (appdata v)
            {
                v2f o;
                o.normal=mul(UNITY_MATRIX_V,v.normal);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col=tex2D(_MainTex,i.uv)+((_FresnelColor*
                max(0,(1-dot(float3(0,0,1),i.normal)-_val))
                ));
              
            
               
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
