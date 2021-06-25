Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _val("val",Range(1,4))=1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma tessellate tess
            #pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : POSITION;
             //s  uint id:gl_PrimitiveIDIn;
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            float _val;
            float4 tess(v2f v1,v2f v2,v2f v3)
            {
                return _val;
            }

            [maxvertexcount(16)]
            void geom(triangle v2f v[3],inout TriangleStream<v2f> ts)
            {
                v2f buf;
               
                for(uint i=0;i<3;i++)
                {
                     int k=1;

                    buf=v[i];
                    buf.vertex+=float4(k,4,4,4);
                ts.Append(buf);
                }
                ts.RestartStrip();
            }
            

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
