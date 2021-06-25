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

        CGPROGRAM
        #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:vert tessellate:tess geometry:geom nolightmap
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
            float3 normal:NORMAL;
            float4 color:COLOR;

        };
        
    
        struct Input
        {
            float2 uv_MainTex;

            float4 color:COLOR;

        };


        void vert(inout appdata I)
        {
            
            I.color=tex2Dlod(_Factor,float4(I.texcoord.xy,0,0));
    
        }

        float4 tess(appdata v1,appdata v2,appdata v3)
        {   
           
            return 1+tex2Dlod(_Factor,float4(v1.texcoord.xy,0,0))*_val;
        }
        [maxvertexcount(32)]
        void geom()
        {
            
        }
        
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            
            // Albedo comes from a texture tinted by color
            fixed4 c = IN.color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }
        ENDCG
    }
}
