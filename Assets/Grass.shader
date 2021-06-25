Shader "Unlit/Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GrassTex("Grass",2D)="white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geo
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = (v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            inline v2f O2P(v2f a)
            {
                v2f buf;
                buf.uv=a.uv;
                buf.vertex=UnityObjectToClipPos(a.vertex);
                return buf;
            }

            [maxvertexcount(36)]
            void geo(triangle v2f a[3],inout TriangleStream<v2f> ts)
            {
                
              
                ts.Append(O2P(a[0]));
                ts.Append(O2P(a[1]));
                ts.Append(O2P(a[2]));
            
                ts.RestartStrip();


                const uint division=3;
                const float height=10.;
                v2f buf;
                for(uint i=0;i<division;i++)
                {
                    float CurrentH=tan(1.0/i+1);

                    buf.vertex=a[0].vertex+mul(unity_ObjectToWorld,float4(-1,CurrentH*1,0,0));
                    buf.uv=float2(0,CurrentH);
                    ts.Append(O2P(buf));
                    buf.vertex=a[0].vertex+mul(unity_ObjectToWorld,float4(1,CurrentH*1,0,0));
                    buf.uv=float2(1,CurrentH);
                    ts.Append(O2P(buf));
                    
                    buf.vertex=a[0].vertex+mul(unity_ObjectToWorld,float4(-1,CurrentH*2,0,0));
                    buf.uv=float2(1,CurrentH);
                    ts.Append(O2P(buf));
                     buf.vertex=a[0].vertex+mul(unity_ObjectToWorld,float4(1,CurrentH*2,0,0));
                    buf.uv=float2(1,CurrentH);
                    ts.Append(O2P(buf));
                ts.RestartStrip();

                }

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
