Shader "Unlit/g"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma hul hull

            #pragma domain dom

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


            //! FUNCTIONS

            struct ControlPoint
            {
                float3 worldpos:WORLDPOS;
                float4 col:COLOR;
            };
            
            struct PatchConstant
            {
                float factor[3]:SV_TESSFACTOR;
                float factor_inside:SV_INSIDETESSFACTOR;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            [patchsize(12)]

            PatchConstant PatchConstFunc(InputPatch<ControlPoint,3> inputPatch,uint patchid:SV_PRIMITIVEID)
            {
                PatchConstant a;
                a.factor[0]=1;
                a.factor[1]=1;
                a.factor[2]=1;
                a.factor_inside=1;
                return a;
            }

            struct HullInput
            {
                float3 pos:POSITION;
                float4 color:COLOR;
            };

            struct HullOutput
            {
                float3 pos:POSITION;
                float4 color:COLOR;
            };

            [UNITY_domain("tri")]
            [UNITY_outputcontrolpoints(3)]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_partitioning("integer")]
            [UNITY_patchconstantfunc("PatchConstFunc")]
            HullOutput hul
            (
            InputPatch<HullInput, 3> ip,
            uint pointid:SV_OUTPUTCONTROLPOINTID
            )
            {
                HullOutput a;
                a.pos=ip[pointid].pos;

                a.color=ip[pointid].color;

                return a;

            }
            


            [domain("tri")]
            void dom(
            PatchConstant factor,
            OutputPatch<HullOutput,3> patch,
            float3 barycentcoords:SV_DOMAINLOCATION
            )
            {
                HullOutput a;
                a.pos=
                patch[0].pos*barycentcoords.x+
                patch[1].pos*barycentcoords.y+
                patch[2].pos*barycentcoords.z;
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
