Shader "Unlit/DepthTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Mask ("mask", 2D) = "white" {}
        
        _Leng ("leng",float)=1
        _Color("col",Color)=(1,1,1,1)
        _Val("val",Range(0,1))=1
        
    }
    SubShader
    {
        
        Tags { "RenderType"="transparent" }
        
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off
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
                float2 depth:TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 vertex2 : POSITION1;
                float3 normal:NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Mask;
            float4 _Mask_ST;
            sampler2D _CameraDepthTexture;
            //float4  _ScreenParams;
            float _Leng;

            float _Val;
            float4 _FresnelColor;
            float4 _Color;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal=mul(UNITY_MATRIX_V,v.normal);

                o.vertex2=mul(UNITY_MATRIX_MV   ,v.vertex);
                COMPUTE_EYEDEPTH(o.depth);
                
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float depth;
                float2 screenpos=i.vertex/_ScreenParams.xy;
                //DECODE_EYEDEPTH(i.vertex2);
                depth=Linear01Depth(i.vertex2.z);


                float col = Linear01Depth((tex2D(_CameraDepthTexture, screenpos)));
                float dif=(col-depth);
                
                float buf=0;
                if(dif>0)
                {
                    buf=1 - smoothstep(0, _ProjectionParams.w * _Leng, dif);
                }

                float4 maskcol=saturate(tex2D(_Mask,i.uv))*2;
                buf=pow(buf,2);
                float mask=maskcol*((_Color*buf)+
                (_Color*
                max(0,(1-dot(float3(0,0,1),i.normal)-_Val))
                ));

        
                mask+=(1-abs(abs(_SinTime.w-i.uv.y)));

                
                return tex2D(_MainTex,i.uv)*mask;
            }
            ENDCG
        }
    }
}
