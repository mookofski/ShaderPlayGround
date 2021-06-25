Shader "Custom/GrassPaint"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _val("val",float)=1
        _Factor("Factor",2D)="white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        pass{
            CGPROGRAM
            //  #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:vert tessellate:tess geometry:geo nolightmap
            #pragma vertex vert
            
            #pragma tessellate tess

           // #pragma geometry geo
            
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma target 4.6
            #include "Tessellation.cginc"

            //! VARIABLES


            sampler2D _MainTex;
            half _Glossiness;
            half _Metallic;
            fixed4 _Color;
            float _val;

            sampler2D _Factor;
            fixed4 _Factor_ST;

            

            //! STRUCTURES   
            struct appdata
            {
                float4 vertex:POSITION;
                float2 texcoord:TEXCOORD;

            };
            
            
            struct Input
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;

            };


            void vert(inout appdata I)
            {
                
                
            }

            float4 tess(appdata v1,appdata v2,appdata v3)
            {   
            return _val;              
//                return tex2Dlod(_Factor,float4(v1.texcoord.xy,0,0))*_val;   
            }
            inline appdata O2P(appdata a)
            {
                appdata buf;
                buf.texcoord=a.texcoord;
                buf.vertex=UnityObjectToClipPos(a.vertex);
                return buf;
            }
            /*
            [maxvertexcount(36)]
            void geo(triangle appdata v[3],inout TriangleStream<appdata> ts)
            {
                ts.Append(O2P(v[0]));
                ts.Append(O2P(v[1]));
                appdata a;
                a.vertex=v[2].vertex+float4(0,1,0,0);
                a.texcoord=v[2].texcoord;
                ts.Append(O2P(a));

                ts.RestartStrip();                
            }
*/
            
            

            fixed4 frag (Input a): SV_Target
            {
                
                // Albedo comes from a texture tinted by color
                return tex2D(_MainTex,a.texcoord);
                //o.Albedo = c.rgb;
                // Metallic and smoothness come from slider variables
                //            o.Alpha = c.a;
            }
            ENDCG
        }
    }
}
