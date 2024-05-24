Shader "VRSL/Custom/JDC1_Base"
{
    Properties
    {
        [Header(Base Properties)]
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MetallicSmoothness ("Metallic(R) / Smoothness(A) Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardDefaultGI
        #include "UnityPBSLighting.cginc"
        #define VRSL_DMX
        #define VRSL_SURFACE

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.5
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float2 uv_MetallicSmoothness;
        };

        #include "Packages/com.acchosen.vr-stage-lighting/Runtime/Shaders/Shared/VRSL-Defines.cginc"
        half _CurveBeam, _CurvePlate;
        #include "Packages/com.acchosen.vr-stage-lighting/Runtime/Shaders/Shared/VRSL-DMXFunctions.cginc"
        //#include "Packages/com.acchosen.vr-stage-lighting/Runtime/Shaders/VRSLDMX.cginc"
        #include "./JDC1-Functions.cginc"

        sampler2D _NormalMap, _MetallicSmoothness;

        inline half4 LightingStandardDefaultGI(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
        { 
            return LightingStandard(s, viewDir, gi);
        }
        inline void LightingStandardDefaultGI_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {             
    
            
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 ms = tex2D (_MetallicSmoothness, IN.uv_MetallicSmoothness);
 
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic * ms.r;
            o.Smoothness = _Glossiness * ms.a;
            o.Alpha = c.a;
            o.Normal = UnpackNormal (tex2D (_NormalMap, IN.uv_NormalMap));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
