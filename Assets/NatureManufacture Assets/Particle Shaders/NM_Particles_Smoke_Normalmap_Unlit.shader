Shader "NatureManufacture/URP/Particles/Smoke Normalmap Unlit"
{
    Properties
    {
        [ToggleUI]_Use_Scene_Light_s_Direction("Use Scene Light's Direction", Float) = 1
        _Light_Direction("Light Direction", Vector) = (0, 0, 0, 0)
        _AlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 1
        _Alpha_Multiplier("Alpha Multiplier", Float) = 1
        [Normal][NoScaleOffset]_Normal_Map("Normal Map", 2D) = "bump" {}
        _Normal_Map_Light_Impact("Normal Map Light Impact", Range(-5, 5)) = 1
        [NoScaleOffset]_Color_Mask_R_Emission_B_Transparency_A("Color mask (R) Emission (B) Transparency (A)", 2D) = "white" {}
        [ToggleUI]_Read_Color_Mask("Read Color Mask", Float) = 1
        _Particle_Color_RGB_Alpha_A("Particle Color (RGB) Alpha (A)", Color) = (1, 1, 1, 1)
        _Color_Blend("Color Blend", Float) = 1
        _Light_Intensity("Light Intensity", Float) = 1
        _Light_Contrast("Light Contrast", Float) = 1
        _Light_Blend_Intensity("Light Blend Intensity", Float) = 1
        _Light_Color("Light Color", Color) = (1, 1, 1, 0)
        _Shadow_Color("Shadow Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_Emission_Gradient("Emission Gradient", 2D) = "white" {}
        [HDR]_Emission_Color("Emission Color", Color) = (0, 0, 0, 0)
        _Emission_Over_Time("Emission Over Time", Float) = 1.5
        _Emission_Gradient_Contrast("Emission Gradient Contrast", Float) = 1
        [ToggleUI]_Emission_From_R_T_From_B_F("Emission From R (T) From B (F)", Float) = 0
        _Intersection_Offset("Intersection Offset", Float) = 0.5
        _CullingStart("Culling Start", Float) = 1
        _CullingDistance("Culling Distance", Float) = 2
        [ToggleUI]_Wind_from_Center_T_Age_F("Wind from Center (T) Age (F)", Float) = 0
        _Gust_Strength("Gust Strength", Float) = 0
        _Shiver_Strength("Shiver Strength", Float) = 0
        _Bend_Strength("Bend Strength", Range(0.1, 4)) = 2
        [Toggle]USE_TRANSPARENCY_INTERSECTION("Use Transparency Intersection", Float) = 0
        [Toggle]EMISSION_PROCEDURAL_MASK("Emission Procedural (T) Mask (F)", Float) = 1
        [Toggle]USE_WIND("Use Wind", Float) = 0
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 1
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 0
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 0
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ USE_TRANSPARENCY_INTERSECTION_ON
        #pragma shader_feature_local _ EMISSION_PROCEDURAL_MASK_ON
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 VertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentWS : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 packed_positionWS_Alpha_Dist : INTERP3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS : INTERP4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.packed_positionWS_Alpha_Dist.xyz = input.positionWS;
            output.packed_positionWS_Alpha_Dist.w = input.Alpha_Dist;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.packed_positionWS_Alpha_Dist.xyz;
            output.Alpha_Dist = input.packed_positionWS_Alpha_Dist.w;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Use_Scene_Light_s_Direction;
        float3 _Light_Direction;
        float _AlphaClipThreshold;
        float _Alpha_Multiplier;
        float4 _Normal_Map_TexelSize;
        float _Normal_Map_Light_Impact;
        float4 _Color_Mask_R_Emission_B_Transparency_A_TexelSize;
        float _Read_Color_Mask;
        float4 _Particle_Color_RGB_Alpha_A;
        float _Color_Blend;
        float _Light_Intensity;
        float _Light_Contrast;
        float _Light_Blend_Intensity;
        float4 _Light_Color;
        float4 _Shadow_Color;
        float4 _Emission_Gradient_TexelSize;
        float4 _Emission_Color;
        float _Emission_Over_Time;
        float _Emission_Gradient_Contrast;
        float _Emission_From_R_T_From_B_F;
        float _Intersection_Offset;
        float _CullingStart;
        float _CullingDistance;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Color_Mask_R_Emission_B_Transparency_A);
        SAMPLER(sampler_Color_Mask_R_Emission_B_Transparency_A);
        TEXTURE2D(_Emission_Gradient);
        SAMPLER(sampler_Emission_Gradient);
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustWorldScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void GetLightData_float(out float3 lightDir, out float3 color){
        color = float3(0, 0, 0);
        
        #ifdef SHADERGRAPH_PREVIEW
        
            lightDir = float3(0.707, 0.707, 0);
        
            color = 128000;
        
        #else
        
          
        
        
        
                Light mainLight = GetMainLight();
        
                lightDir = -mainLight.direction;
        
                color = mainLight.color;
        
          
        
        #endif
        }
        
        void Unity_Clamp_float3(float3 In, float3 Min, float3 Max, out float3 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        struct Bindings_LightDataURP_a02ff11a29d676645b44ec159fdb9001_float
        {
        };
        
        void SG_LightDataURP_a02ff11a29d676645b44ec159fdb9001_float(Bindings_LightDataURP_a02ff11a29d676645b44ec159fdb9001_float IN, out float3 Direction_1, out float3 Color_2)
        {
        float3 _GetLightDataCustomFunction_7080735260b3168baa0a08cab565a2c1_lightDir_0_Vector3;
        float3 _GetLightDataCustomFunction_7080735260b3168baa0a08cab565a2c1_color_1_Vector3;
        GetLightData_float(_GetLightDataCustomFunction_7080735260b3168baa0a08cab565a2c1_lightDir_0_Vector3, _GetLightDataCustomFunction_7080735260b3168baa0a08cab565a2c1_color_1_Vector3);
        float3 _Clamp_d0e121f15e9b4bc78655a4ed324774b9_Out_3_Vector3;
        Unity_Clamp_float3(_GetLightDataCustomFunction_7080735260b3168baa0a08cab565a2c1_lightDir_0_Vector3, float3(-1, -1, -1), float3(1, 1, 1), _Clamp_d0e121f15e9b4bc78655a4ed324774b9_Out_3_Vector3);
        float3 _Clamp_cae8c421a0c141f79e638702618f11ad_Out_3_Vector3;
        Unity_Clamp_float3(_GetLightDataCustomFunction_7080735260b3168baa0a08cab565a2c1_color_1_Vector3, float3(0.01, 0.01, 0.01), float3(1000000, 100000, 100000), _Clamp_cae8c421a0c141f79e638702618f11ad_Out_3_Vector3);
        Direction_1 = _Clamp_d0e121f15e9b4bc78655a4ed324774b9_Out_3_Vector3;
        Color_2 = _Clamp_cae8c421a0c141f79e638702618f11ad_Out_3_Vector3;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_MatrixConstruction_Column_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M1.x, M2.x, M3.x, M0.y, M1.y, M2.y, M3.y, M0.z, M1.z, M2.z, M3.z, M0.w, M1.w, M2.w, M3.w);
            Out3x3 = float3x3(M0.x, M1.x, M2.x, M0.y, M1.y, M2.y, M0.z, M1.z, M2.z);
            Out2x2 = float2x2(M0.x, M1.x, M0.y, M1.y);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float3x3_float3(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Alpha_Dist;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float = _CullingDistance;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float = _CullingStart;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float;
            Unity_Subtract_float(_Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float, _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float, _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float;
            Unity_Divide_float(_Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float, _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float, _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            Unity_Saturate_float(_Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float, _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_46678044b69341a48cefb2cba33ed79a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_46678044b69341a48cefb2cba33ed79a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_46678044b69341a48cefb2cba33ed79a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_46678044b69341a48cefb2cba33ed79a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[0];
            float _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[1];
            float _Split_9fde5fb7f6864cefa72dada578d17557_B_3_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[2];
            float _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float;
            Unity_Multiply_float_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, 0.5, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float;
            Unity_Subtract_float(_Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_46678044b69341a48cefb2cba33ed79a_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float, 0, _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_169ba66547c24fa7a9cef296b67139b3_R_1_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[0];
            float _Split_169ba66547c24fa7a9cef296b67139b3_G_2_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[1];
            float _Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[2];
            float _Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float;
            Unity_Branch_float(_Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3 = float3(_Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3;
            _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3 = TransformObjectToWorld(_Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3, (_Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float.xxx), _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3, _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3, _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3, (_Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float.xxx), _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[0];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_G_2_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[1];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[2];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4;
            float3 _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3;
            float2 _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2;
            Unity_Combine_float(_Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float, _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float, 0, 0, _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4, _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3, _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.tex, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.samplerstate, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.GetTransformedUV(_Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_G_6_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_B_7_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_A_8_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float;
            Unity_Branch_float(_Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean, _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float, 0, _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float;
            Unity_Absolute_float(_Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float, _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float;
            Unity_Power_float(_Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float, 2, _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float;
            Unity_Multiply_float_float(_Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float, _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float, _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[0];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_G_2_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[1];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[2];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_A_4_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2 = float2(_Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float, _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_3fc88fa712b44aeaab8f41107199bc74_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float;
            Unity_Subtract_float(_Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float;
            Unity_Clamp_float(_Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float, 0.0001, 1000, _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float;
            Unity_Divide_float(_Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float;
            Unity_Absolute_float(_Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float, _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float;
            Unity_Power_float(_Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float, _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float, _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float;
            Unity_Multiply_float_float(_Power_ad608225df654ce094ffb8b933e16525_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float;
            Unity_Absolute_float(_Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float, _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float;
            Unity_Power_float(_Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float, _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float, _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float;
            Unity_SquareRoot_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float;
            Unity_Multiply_float_float(_Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float;
            Unity_Branch_float(_Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float;
            Unity_Multiply_float_float(_Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2, (_Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float.xx), _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5093515884134bcb9155fab829022fce_R_1_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[0];
            float _Split_5093515884134bcb9155fab829022fce_G_2_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[1];
            float _Split_5093515884134bcb9155fab829022fce_B_3_Float = 0;
            float _Split_5093515884134bcb9155fab829022fce_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3 = float3(_Split_5093515884134bcb9155fab829022fce_R_1_Float, 0, _Split_5093515884134bcb9155fab829022fce_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float.xxx), _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3;
            Unity_Add_float3(_Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c9aaa3880e954454a02d36009c8e9e68_R_1_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[0];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_G_2_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[1];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_B_3_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[2];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3, (_Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float.xxx), _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3, _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3, (_Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float.xxx), _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[0];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_G_2_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[1];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[2];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4;
            float3 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3;
            float2 _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2;
            Unity_Combine_float(_Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float, _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float, 0, 0, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3, _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.tex, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.samplerstate, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.GetTransformedUV(_Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_A_8_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4;
            float3 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3;
            float2 _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float, 0, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3;
            Unity_Add_float3(_Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3, (_Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float.xxx), _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float;
            Unity_Multiply_float_float(_Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3, (_Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float.xxx), _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_b0b77f3ff3554aaa991ca36800c29365_R_1_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[0];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[1];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_B_3_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[2];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3;
            Unity_Add_float3(_Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean, _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3;
            Unity_Add_float3(_Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            Unity_Branch_float3(_Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3, _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3, _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            #else
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.Alpha_Dist = _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Alpha_Dist = input.Alpha_Dist;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_cd89dbbc71dc4524b066b0c13fd5d07f_Out_0_Vector4 = _Light_Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_LightDataURP_a02ff11a29d676645b44ec159fdb9001_float _LightDataURP_ef35e0c3b353486fb2d6cf09993461d7;
            float3 _LightDataURP_ef35e0c3b353486fb2d6cf09993461d7_Direction_1_Vector3;
            float3 _LightDataURP_ef35e0c3b353486fb2d6cf09993461d7_Color_2_Vector3;
            SG_LightDataURP_a02ff11a29d676645b44ec159fdb9001_float(_LightDataURP_ef35e0c3b353486fb2d6cf09993461d7, _LightDataURP_ef35e0c3b353486fb2d6cf09993461d7_Direction_1_Vector3, _LightDataURP_ef35e0c3b353486fb2d6cf09993461d7_Color_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Normalize_ccb6bbde886947e59d31788f3b3fb601_Out_1_Vector3;
            Unity_Normalize_float3(_LightDataURP_ef35e0c3b353486fb2d6cf09993461d7_Color_2_Vector3, _Normalize_ccb6bbde886947e59d31788f3b3fb601_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b0b73453faf94ab7af586460c8d85119_Out_0_Float = _Light_Blend_Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Lerp_2e4de65c253544cea857f931c5c41e4a_Out_3_Vector3;
            Unity_Lerp_float3((_Property_cd89dbbc71dc4524b066b0c13fd5d07f_Out_0_Vector4.xyz), _Normalize_ccb6bbde886947e59d31788f3b3fb601_Out_1_Vector3, (_Property_b0b73453faf94ab7af586460c8d85119_Out_0_Float.xxx), _Lerp_2e4de65c253544cea857f931c5c41e4a_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4443887f313f46b68e51dbd246596db0_Out_0_Boolean = _Use_Scene_Light_s_Direction;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Property_efdf3dbd0f7c46ba84d6cd65fcbe176c_Out_0_Vector3 = _Light_Direction;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_b33b3f03bd604a6a9de5318fdcf8a72e_Out_3_Vector3;
            Unity_Branch_float3(_Property_4443887f313f46b68e51dbd246596db0_Out_0_Boolean, _LightDataURP_ef35e0c3b353486fb2d6cf09993461d7_Direction_1_Vector3, _Property_efdf3dbd0f7c46ba84d6cd65fcbe176c_Out_0_Vector3, _Branch_b33b3f03bd604a6a9de5318fdcf8a72e_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4x4 _MatrixConstruction_1ffada697927453ea33a4d6f3e326de6_var4x4_4_Matrix4;
            float3x3 _MatrixConstruction_1ffada697927453ea33a4d6f3e326de6_var3x3_5_Matrix3;
            float2x2 _MatrixConstruction_1ffada697927453ea33a4d6f3e326de6_var2x2_6_Matrix2;
            Unity_MatrixConstruction_Column_float((float4(IN.ObjectSpaceTangent, 1.0)), (float4(IN.ObjectSpaceBiTangent, 1.0)), (float4(IN.ObjectSpaceNormal, 1.0)), float4 (0, 0, 0, 0), _MatrixConstruction_1ffada697927453ea33a4d6f3e326de6_var4x4_4_Matrix4, _MatrixConstruction_1ffada697927453ea33a4d6f3e326de6_var3x3_5_Matrix3, _MatrixConstruction_1ffada697927453ea33a4d6f3e326de6_var2x2_6_Matrix2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_bb46bc5446944be59c90fb52f06d7a66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Normal_Map);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bb46bc5446944be59c90fb52f06d7a66_Out_0_Texture2D.tex, _Property_bb46bc5446944be59c90fb52f06d7a66_Out_0_Texture2D.samplerstate, _Property_bb46bc5446944be59c90fb52f06d7a66_Out_0_Texture2D.GetTransformedUV((_UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4.xy)) );
            _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_RGBA_0_Vector4);
            float _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_R_4_Float = _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_RGBA_0_Vector4.r;
            float _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_G_5_Float = _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_RGBA_0_Vector4.g;
            float _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_B_6_Float = _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_RGBA_0_Vector4.b;
            float _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_A_7_Float = _SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bbeef53bb4c54aa097c2a07da8bc2c88_Out_0_Float = _Normal_Map_Light_Impact;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _NormalStrength_dd2b823f401d4fd6b899ff52d16e20a2_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_0ed25a5d03077d89ba21a94bf21a8a6e_RGBA_0_Vector4.xyz), _Property_bbeef53bb4c54aa097c2a07da8bc2c88_Out_0_Float, _NormalStrength_dd2b823f401d4fd6b899ff52d16e20a2_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_40ca3a9f600c4250ae9148e0fffd87b4_Out_2_Vector3;
            Unity_Multiply_float3x3_float3(_MatrixConstruction_1ffada697927453ea33a4d6f3e326de6_var3x3_5_Matrix3, _NormalStrength_dd2b823f401d4fd6b899ff52d16e20a2_Out_2_Vector3, _Multiply_40ca3a9f600c4250ae9148e0fffd87b4_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _DotProduct_51413d029f5b4262b849994a306f2815_Out_2_Float;
            Unity_DotProduct_float3(_Branch_b33b3f03bd604a6a9de5318fdcf8a72e_Out_3_Vector3, _Multiply_40ca3a9f600c4250ae9148e0fffd87b4_Out_2_Vector3, _DotProduct_51413d029f5b4262b849994a306f2815_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_6f31489e018a48d1a80e499cfb402922_Out_2_Float;
            Unity_Add_float(_DotProduct_51413d029f5b4262b849994a306f2815_Out_2_Float, 1, _Add_6f31489e018a48d1a80e499cfb402922_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_c21e3d99c9444d3f990cfea079a91532_Out_2_Float;
            Unity_Multiply_float_float(_Add_6f31489e018a48d1a80e499cfb402922_Out_2_Float, 0.5, _Multiply_c21e3d99c9444d3f990cfea079a91532_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e01d23a193574cca823b1f4c8488a0b3_Out_0_Float = _Light_Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_2f0d470962ea4db6a784c4b5887a326b_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_c21e3d99c9444d3f990cfea079a91532_Out_2_Float, _Property_e01d23a193574cca823b1f4c8488a0b3_Out_0_Float, _Multiply_2f0d470962ea4db6a784c4b5887a326b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_80501e4f45254b4fab2f1ad6174b22f1_Out_0_Float = _Light_Contrast;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Contrast_14a19f9741ce49e08fbf2a7615eeb015_Out_2_Vector3;
            Unity_Contrast_float((_Multiply_2f0d470962ea4db6a784c4b5887a326b_Out_2_Float.xxx), _Property_80501e4f45254b4fab2f1ad6174b22f1_Out_0_Float, _Contrast_14a19f9741ce49e08fbf2a7615eeb015_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_412fc12e3e5f403cb5d1c8ddc15973d8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Lerp_2e4de65c253544cea857f931c5c41e4a_Out_3_Vector3, _Contrast_14a19f9741ce49e08fbf2a7615eeb015_Out_2_Vector3, _Multiply_412fc12e3e5f403cb5d1c8ddc15973d8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_52d05deb561b4fb2905d34805c926c61_Out_0_Vector4 = _Shadow_Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_7320242a514d4dd1b6a21d6793eab70a_Out_2_Vector3;
            Unity_Add_float3(_Multiply_412fc12e3e5f403cb5d1c8ddc15973d8_Out_2_Vector3, (_Property_52d05deb561b4fb2905d34805c926c61_Out_0_Vector4.xyz), _Add_7320242a514d4dd1b6a21d6793eab70a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b4e0c30cf01756839030a5167b089dc6_Out_0_Boolean = _Read_Color_Mask;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Color_Mask_R_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.tex, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.samplerstate, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.GetTransformedUV((_UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4.xy)) );
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_R_4_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_G_5_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_B_6_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4 = _Particle_Color_RGB_Alpha_A;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_596710b2cf0e45708d9cc363643bd02a_Out_0_Float = _Color_Blend;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Lerp_31b84a9878b949fdaf84fc9c107d9c56_Out_3_Vector4;
            Unity_Lerp_float4((_SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_R_4_Float.xxxx), _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4, (_Property_596710b2cf0e45708d9cc363643bd02a_Out_0_Float.xxxx), _Lerp_31b84a9878b949fdaf84fc9c107d9c56_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Branch_ef8236ada61be1869b3278db6ae02537_Out_3_Vector4;
            Unity_Branch_float4(_Property_b4e0c30cf01756839030a5167b089dc6_Out_0_Boolean, _Lerp_31b84a9878b949fdaf84fc9c107d9c56_Out_3_Vector4, _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4, _Branch_ef8236ada61be1869b3278db6ae02537_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_3c7c94a1a6e2c08786b9b70a13b426fa_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Branch_ef8236ada61be1869b3278db6ae02537_Out_3_Vector4, _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4, _Multiply_3c7c94a1a6e2c08786b9b70a13b426fa_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_39231bd5410441cdb7194e3b7cc11f47_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_7320242a514d4dd1b6a21d6793eab70a_Out_2_Vector3, (_Multiply_3c7c94a1a6e2c08786b9b70a13b426fa_Out_2_Vector4.xyz), _Multiply_39231bd5410441cdb7194e3b7cc11f47_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a4bf820b71154422a321ca28e911233e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emission_Gradient);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_ccbdca8664504a5b8e539ab18805fb84_Out_0_Vector2 = float2(_Multiply_c21e3d99c9444d3f990cfea079a91532_Out_2_Float, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a4bf820b71154422a321ca28e911233e_Out_0_Texture2D.tex, _Property_a4bf820b71154422a321ca28e911233e_Out_0_Texture2D.samplerstate, _Property_a4bf820b71154422a321ca28e911233e_Out_0_Texture2D.GetTransformedUV(_Vector2_ccbdca8664504a5b8e539ab18805fb84_Out_0_Vector2) );
            float _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_R_4_Float = _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_RGBA_0_Vector4.r;
            float _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_G_5_Float = _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_RGBA_0_Vector4.g;
            float _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_B_6_Float = _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_RGBA_0_Vector4.b;
            float _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_A_7_Float = _SampleTexture2D_41d68813776d4bafa535e5ee330dada2_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_3231da6193d64e80a8349c56fcf4c0e6_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Emission_Color) : _Emission_Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_d4bae9c5e8ef4601b953b90a485de44a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_41d68813776d4bafa535e5ee330dada2_RGBA_0_Vector4, _Property_3231da6193d64e80a8349c56fcf4c0e6_Out_0_Vector4, _Multiply_d4bae9c5e8ef4601b953b90a485de44a_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_78fcfdf9805a4c57a8d6de5a0ca4f515_R_1_Float = _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4[0];
            float _Split_78fcfdf9805a4c57a8d6de5a0ca4f515_G_2_Float = _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4[1];
            float _Split_78fcfdf9805a4c57a8d6de5a0ca4f515_B_3_Float = _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4[2];
            float _Split_78fcfdf9805a4c57a8d6de5a0ca4f515_A_4_Float = _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fd3cbf470e634482bc099ecf9d5d64e1_Out_0_Float = _Emission_Gradient_Contrast;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_8993563f17ba452c9e6d53c768836b9d_Out_2_Float;
            Unity_Multiply_float_float(_Split_78fcfdf9805a4c57a8d6de5a0ca4f515_B_3_Float, _Property_fd3cbf470e634482bc099ecf9d5d64e1_Out_0_Float, _Multiply_8993563f17ba452c9e6d53c768836b9d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4529c52739f14edd9efd692c80c86f1f_Out_0_Float = _Emission_Over_Time;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_22440300824d440e91c3e00df140dca3_Out_2_Float;
            Unity_Subtract_float(_Multiply_8993563f17ba452c9e6d53c768836b9d_Out_2_Float, _Property_4529c52739f14edd9efd692c80c86f1f_Out_0_Float, _Subtract_22440300824d440e91c3e00df140dca3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_45f2c9b64577420bad23cb0a8e8c3790_Out_2_Float;
            Unity_Power_float(_Subtract_22440300824d440e91c3e00df140dca3_Out_2_Float, 3, _Power_45f2c9b64577420bad23cb0a8e8c3790_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_384cb801d77348609aa06c35221250dc_Out_2_Float;
            Unity_Multiply_float_float(_Power_45f2c9b64577420bad23cb0a8e8c3790_Out_2_Float, -1, _Multiply_384cb801d77348609aa06c35221250dc_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Saturate_348830156bc54908aa8ed86ae90686b2_Out_1_Float;
            Unity_Saturate_float(_Multiply_384cb801d77348609aa06c35221250dc_Out_2_Float, _Saturate_348830156bc54908aa8ed86ae90686b2_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_52ded104003144e4885752c3156f504d_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_d4bae9c5e8ef4601b953b90a485de44a_Out_2_Vector4, (_Saturate_348830156bc54908aa8ed86ae90686b2_Out_1_Float.xxxx), _Multiply_52ded104003144e4885752c3156f504d_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_aeaa233470cc43049c76cc6fa5d1857b_Out_0_Boolean = _Emission_From_R_T_From_B_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_fca2b98817db47109a61a5dade5b18a0_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_R_4_Float, _OneMinus_fca2b98817db47109a61a5dade5b18a0_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_79266e1a5d4d4600b6d4b77228cd2392_Out_3_Float;
            Unity_Branch_float(_Property_aeaa233470cc43049c76cc6fa5d1857b_Out_0_Boolean, _OneMinus_fca2b98817db47109a61a5dade5b18a0_Out_1_Float, _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_B_6_Float, _Branch_79266e1a5d4d4600b6d4b77228cd2392_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_722900f84c0c4b4f98075fea4a331412_Out_2_Float;
            Unity_Multiply_float_float(_Branch_79266e1a5d4d4600b6d4b77228cd2392_Out_3_Float, _Saturate_348830156bc54908aa8ed86ae90686b2_Out_1_Float, _Multiply_722900f84c0c4b4f98075fea4a331412_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_430f290dd9ca4bf9879a6fa1804dca53_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3231da6193d64e80a8349c56fcf4c0e6_Out_0_Vector4, (_Multiply_722900f84c0c4b4f98075fea4a331412_Out_2_Float.xxxx), _Multiply_430f290dd9ca4bf9879a6fa1804dca53_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(EMISSION_PROCEDURAL_MASK_ON)
            float4 _EmissionProceduralTMaskF_48d7f3f2b2904e02919072153ac0b668_Out_0_Vector4 = _Multiply_52ded104003144e4885752c3156f504d_Out_2_Vector4;
            #else
            float4 _EmissionProceduralTMaskF_48d7f3f2b2904e02919072153ac0b668_Out_0_Vector4 = _Multiply_430f290dd9ca4bf9879a6fa1804dca53_Out_2_Vector4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_7ff56cc285bc4460aa770e8391ba1f8b_Out_2_Vector3;
            Unity_Add_float3(_Multiply_39231bd5410441cdb7194e3b7cc11f47_Out_2_Vector3, (_EmissionProceduralTMaskF_48d7f3f2b2904e02919072153ac0b668_Out_0_Vector4.xyz), _Add_7ff56cc285bc4460aa770e8391ba1f8b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_R_1_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[0];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_G_2_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[1];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_B_3_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[2];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float;
            Unity_Multiply_float_float(_Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float, _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float, _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float, _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.BaseColor = _Add_7ff56cc285bc4460aa770e8391ba1f8b_Out_2_Vector3;
            surface.Alpha = _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float;
            surface.AlphaClipThreshold = _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Alpha_Dist = input.Alpha_Dist;
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        // use bitangent on the fly like in hdrp
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal = normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpaceBiTangent = renormFactor * bitang;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent = TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceBiTangent = TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.VertexColor = input.color;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ USE_TRANSPARENCY_INTERSECTION_ON
        #pragma shader_feature_local _ EMISSION_PROCEDURAL_MASK_ON
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 VertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 packed_positionWS_Alpha_Dist : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.packed_positionWS_Alpha_Dist.xyz = input.positionWS;
            output.packed_positionWS_Alpha_Dist.w = input.Alpha_Dist;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.packed_positionWS_Alpha_Dist.xyz;
            output.Alpha_Dist = input.packed_positionWS_Alpha_Dist.w;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Use_Scene_Light_s_Direction;
        float3 _Light_Direction;
        float _AlphaClipThreshold;
        float _Alpha_Multiplier;
        float4 _Normal_Map_TexelSize;
        float _Normal_Map_Light_Impact;
        float4 _Color_Mask_R_Emission_B_Transparency_A_TexelSize;
        float _Read_Color_Mask;
        float4 _Particle_Color_RGB_Alpha_A;
        float _Color_Blend;
        float _Light_Intensity;
        float _Light_Contrast;
        float _Light_Blend_Intensity;
        float4 _Light_Color;
        float4 _Shadow_Color;
        float4 _Emission_Gradient_TexelSize;
        float4 _Emission_Color;
        float _Emission_Over_Time;
        float _Emission_Gradient_Contrast;
        float _Emission_From_R_T_From_B_F;
        float _Intersection_Offset;
        float _CullingStart;
        float _CullingDistance;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Color_Mask_R_Emission_B_Transparency_A);
        SAMPLER(sampler_Color_Mask_R_Emission_B_Transparency_A);
        TEXTURE2D(_Emission_Gradient);
        SAMPLER(sampler_Emission_Gradient);
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustWorldScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Alpha_Dist;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float = _CullingDistance;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float = _CullingStart;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float;
            Unity_Subtract_float(_Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float, _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float, _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float;
            Unity_Divide_float(_Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float, _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float, _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            Unity_Saturate_float(_Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float, _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_46678044b69341a48cefb2cba33ed79a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_46678044b69341a48cefb2cba33ed79a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_46678044b69341a48cefb2cba33ed79a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_46678044b69341a48cefb2cba33ed79a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[0];
            float _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[1];
            float _Split_9fde5fb7f6864cefa72dada578d17557_B_3_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[2];
            float _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float;
            Unity_Multiply_float_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, 0.5, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float;
            Unity_Subtract_float(_Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_46678044b69341a48cefb2cba33ed79a_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float, 0, _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_169ba66547c24fa7a9cef296b67139b3_R_1_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[0];
            float _Split_169ba66547c24fa7a9cef296b67139b3_G_2_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[1];
            float _Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[2];
            float _Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float;
            Unity_Branch_float(_Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3 = float3(_Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3;
            _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3 = TransformObjectToWorld(_Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3, (_Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float.xxx), _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3, _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3, _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3, (_Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float.xxx), _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[0];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_G_2_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[1];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[2];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4;
            float3 _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3;
            float2 _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2;
            Unity_Combine_float(_Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float, _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float, 0, 0, _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4, _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3, _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.tex, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.samplerstate, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.GetTransformedUV(_Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_G_6_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_B_7_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_A_8_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float;
            Unity_Branch_float(_Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean, _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float, 0, _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float;
            Unity_Absolute_float(_Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float, _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float;
            Unity_Power_float(_Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float, 2, _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float;
            Unity_Multiply_float_float(_Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float, _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float, _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[0];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_G_2_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[1];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[2];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_A_4_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2 = float2(_Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float, _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_3fc88fa712b44aeaab8f41107199bc74_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float;
            Unity_Subtract_float(_Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float;
            Unity_Clamp_float(_Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float, 0.0001, 1000, _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float;
            Unity_Divide_float(_Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float;
            Unity_Absolute_float(_Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float, _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float;
            Unity_Power_float(_Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float, _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float, _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float;
            Unity_Multiply_float_float(_Power_ad608225df654ce094ffb8b933e16525_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float;
            Unity_Absolute_float(_Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float, _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float;
            Unity_Power_float(_Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float, _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float, _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float;
            Unity_SquareRoot_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float;
            Unity_Multiply_float_float(_Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float;
            Unity_Branch_float(_Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float;
            Unity_Multiply_float_float(_Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2, (_Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float.xx), _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5093515884134bcb9155fab829022fce_R_1_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[0];
            float _Split_5093515884134bcb9155fab829022fce_G_2_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[1];
            float _Split_5093515884134bcb9155fab829022fce_B_3_Float = 0;
            float _Split_5093515884134bcb9155fab829022fce_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3 = float3(_Split_5093515884134bcb9155fab829022fce_R_1_Float, 0, _Split_5093515884134bcb9155fab829022fce_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float.xxx), _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3;
            Unity_Add_float3(_Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c9aaa3880e954454a02d36009c8e9e68_R_1_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[0];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_G_2_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[1];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_B_3_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[2];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3, (_Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float.xxx), _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3, _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3, (_Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float.xxx), _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[0];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_G_2_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[1];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[2];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4;
            float3 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3;
            float2 _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2;
            Unity_Combine_float(_Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float, _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float, 0, 0, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3, _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.tex, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.samplerstate, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.GetTransformedUV(_Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_A_8_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4;
            float3 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3;
            float2 _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float, 0, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3;
            Unity_Add_float3(_Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3, (_Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float.xxx), _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float;
            Unity_Multiply_float_float(_Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3, (_Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float.xxx), _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_b0b77f3ff3554aaa991ca36800c29365_R_1_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[0];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[1];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_B_3_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[2];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3;
            Unity_Add_float3(_Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean, _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3;
            Unity_Add_float3(_Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            Unity_Branch_float3(_Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3, _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3, _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            #else
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.Alpha_Dist = _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Alpha_Dist = input.Alpha_Dist;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4 = _Particle_Color_RGB_Alpha_A;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_R_1_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[0];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_G_2_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[1];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_B_3_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[2];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Color_Mask_R_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.tex, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.samplerstate, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.GetTransformedUV((_UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4.xy)) );
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_R_4_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_G_5_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_B_6_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float;
            Unity_Multiply_float_float(_Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float, _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float, _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float, _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float;
            surface.AlphaClipThreshold = _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Alpha_Dist = input.Alpha_Dist;
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.VertexColor = input.color;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ USE_TRANSPARENCY_INTERSECTION_ON
        #pragma shader_feature_local _ EMISSION_PROCEDURAL_MASK_ON
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 VertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 packed_positionWS_Alpha_Dist : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS : INTERP3;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.packed_positionWS_Alpha_Dist.xyz = input.positionWS;
            output.packed_positionWS_Alpha_Dist.w = input.Alpha_Dist;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.packed_positionWS_Alpha_Dist.xyz;
            output.Alpha_Dist = input.packed_positionWS_Alpha_Dist.w;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Use_Scene_Light_s_Direction;
        float3 _Light_Direction;
        float _AlphaClipThreshold;
        float _Alpha_Multiplier;
        float4 _Normal_Map_TexelSize;
        float _Normal_Map_Light_Impact;
        float4 _Color_Mask_R_Emission_B_Transparency_A_TexelSize;
        float _Read_Color_Mask;
        float4 _Particle_Color_RGB_Alpha_A;
        float _Color_Blend;
        float _Light_Intensity;
        float _Light_Contrast;
        float _Light_Blend_Intensity;
        float4 _Light_Color;
        float4 _Shadow_Color;
        float4 _Emission_Gradient_TexelSize;
        float4 _Emission_Color;
        float _Emission_Over_Time;
        float _Emission_Gradient_Contrast;
        float _Emission_From_R_T_From_B_F;
        float _Intersection_Offset;
        float _CullingStart;
        float _CullingDistance;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Color_Mask_R_Emission_B_Transparency_A);
        SAMPLER(sampler_Color_Mask_R_Emission_B_Transparency_A);
        TEXTURE2D(_Emission_Gradient);
        SAMPLER(sampler_Emission_Gradient);
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustWorldScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Alpha_Dist;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float = _CullingDistance;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float = _CullingStart;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float;
            Unity_Subtract_float(_Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float, _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float, _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float;
            Unity_Divide_float(_Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float, _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float, _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            Unity_Saturate_float(_Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float, _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_46678044b69341a48cefb2cba33ed79a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_46678044b69341a48cefb2cba33ed79a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_46678044b69341a48cefb2cba33ed79a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_46678044b69341a48cefb2cba33ed79a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[0];
            float _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[1];
            float _Split_9fde5fb7f6864cefa72dada578d17557_B_3_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[2];
            float _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float;
            Unity_Multiply_float_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, 0.5, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float;
            Unity_Subtract_float(_Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_46678044b69341a48cefb2cba33ed79a_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float, 0, _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_169ba66547c24fa7a9cef296b67139b3_R_1_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[0];
            float _Split_169ba66547c24fa7a9cef296b67139b3_G_2_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[1];
            float _Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[2];
            float _Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float;
            Unity_Branch_float(_Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3 = float3(_Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3;
            _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3 = TransformObjectToWorld(_Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3, (_Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float.xxx), _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3, _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3, _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3, (_Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float.xxx), _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[0];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_G_2_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[1];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[2];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4;
            float3 _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3;
            float2 _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2;
            Unity_Combine_float(_Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float, _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float, 0, 0, _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4, _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3, _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.tex, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.samplerstate, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.GetTransformedUV(_Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_G_6_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_B_7_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_A_8_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float;
            Unity_Branch_float(_Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean, _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float, 0, _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float;
            Unity_Absolute_float(_Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float, _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float;
            Unity_Power_float(_Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float, 2, _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float;
            Unity_Multiply_float_float(_Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float, _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float, _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[0];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_G_2_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[1];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[2];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_A_4_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2 = float2(_Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float, _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_3fc88fa712b44aeaab8f41107199bc74_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float;
            Unity_Subtract_float(_Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float;
            Unity_Clamp_float(_Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float, 0.0001, 1000, _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float;
            Unity_Divide_float(_Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float;
            Unity_Absolute_float(_Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float, _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float;
            Unity_Power_float(_Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float, _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float, _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float;
            Unity_Multiply_float_float(_Power_ad608225df654ce094ffb8b933e16525_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float;
            Unity_Absolute_float(_Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float, _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float;
            Unity_Power_float(_Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float, _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float, _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float;
            Unity_SquareRoot_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float;
            Unity_Multiply_float_float(_Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float;
            Unity_Branch_float(_Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float;
            Unity_Multiply_float_float(_Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2, (_Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float.xx), _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5093515884134bcb9155fab829022fce_R_1_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[0];
            float _Split_5093515884134bcb9155fab829022fce_G_2_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[1];
            float _Split_5093515884134bcb9155fab829022fce_B_3_Float = 0;
            float _Split_5093515884134bcb9155fab829022fce_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3 = float3(_Split_5093515884134bcb9155fab829022fce_R_1_Float, 0, _Split_5093515884134bcb9155fab829022fce_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float.xxx), _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3;
            Unity_Add_float3(_Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c9aaa3880e954454a02d36009c8e9e68_R_1_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[0];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_G_2_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[1];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_B_3_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[2];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3, (_Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float.xxx), _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3, _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3, (_Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float.xxx), _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[0];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_G_2_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[1];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[2];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4;
            float3 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3;
            float2 _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2;
            Unity_Combine_float(_Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float, _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float, 0, 0, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3, _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.tex, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.samplerstate, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.GetTransformedUV(_Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_A_8_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4;
            float3 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3;
            float2 _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float, 0, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3;
            Unity_Add_float3(_Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3, (_Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float.xxx), _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float;
            Unity_Multiply_float_float(_Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3, (_Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float.xxx), _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_b0b77f3ff3554aaa991ca36800c29365_R_1_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[0];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[1];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_B_3_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[2];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3;
            Unity_Add_float3(_Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean, _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3;
            Unity_Add_float3(_Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            Unity_Branch_float3(_Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3, _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3, _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            #else
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.Alpha_Dist = _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Alpha_Dist = input.Alpha_Dist;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4 = _Particle_Color_RGB_Alpha_A;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_R_1_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[0];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_G_2_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[1];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_B_3_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[2];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Color_Mask_R_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.tex, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.samplerstate, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.GetTransformedUV((_UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4.xy)) );
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_R_4_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_G_5_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_B_6_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float;
            Unity_Multiply_float_float(_Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float, _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float, _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float, _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float;
            surface.AlphaClipThreshold = _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Alpha_Dist = input.Alpha_Dist;
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.VertexColor = input.color;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ USE_TRANSPARENCY_INTERSECTION_ON
        #pragma shader_feature_local _ EMISSION_PROCEDURAL_MASK_ON
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 VertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 packed_positionWS_Alpha_Dist : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS : INTERP3;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.packed_positionWS_Alpha_Dist.xyz = input.positionWS;
            output.packed_positionWS_Alpha_Dist.w = input.Alpha_Dist;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.packed_positionWS_Alpha_Dist.xyz;
            output.Alpha_Dist = input.packed_positionWS_Alpha_Dist.w;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Use_Scene_Light_s_Direction;
        float3 _Light_Direction;
        float _AlphaClipThreshold;
        float _Alpha_Multiplier;
        float4 _Normal_Map_TexelSize;
        float _Normal_Map_Light_Impact;
        float4 _Color_Mask_R_Emission_B_Transparency_A_TexelSize;
        float _Read_Color_Mask;
        float4 _Particle_Color_RGB_Alpha_A;
        float _Color_Blend;
        float _Light_Intensity;
        float _Light_Contrast;
        float _Light_Blend_Intensity;
        float4 _Light_Color;
        float4 _Shadow_Color;
        float4 _Emission_Gradient_TexelSize;
        float4 _Emission_Color;
        float _Emission_Over_Time;
        float _Emission_Gradient_Contrast;
        float _Emission_From_R_T_From_B_F;
        float _Intersection_Offset;
        float _CullingStart;
        float _CullingDistance;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Color_Mask_R_Emission_B_Transparency_A);
        SAMPLER(sampler_Color_Mask_R_Emission_B_Transparency_A);
        TEXTURE2D(_Emission_Gradient);
        SAMPLER(sampler_Emission_Gradient);
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustWorldScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Alpha_Dist;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float = _CullingDistance;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float = _CullingStart;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float;
            Unity_Subtract_float(_Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float, _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float, _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float;
            Unity_Divide_float(_Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float, _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float, _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            Unity_Saturate_float(_Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float, _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_46678044b69341a48cefb2cba33ed79a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_46678044b69341a48cefb2cba33ed79a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_46678044b69341a48cefb2cba33ed79a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_46678044b69341a48cefb2cba33ed79a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[0];
            float _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[1];
            float _Split_9fde5fb7f6864cefa72dada578d17557_B_3_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[2];
            float _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float;
            Unity_Multiply_float_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, 0.5, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float;
            Unity_Subtract_float(_Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_46678044b69341a48cefb2cba33ed79a_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float, 0, _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_169ba66547c24fa7a9cef296b67139b3_R_1_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[0];
            float _Split_169ba66547c24fa7a9cef296b67139b3_G_2_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[1];
            float _Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[2];
            float _Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float;
            Unity_Branch_float(_Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3 = float3(_Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3;
            _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3 = TransformObjectToWorld(_Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3, (_Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float.xxx), _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3, _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3, _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3, (_Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float.xxx), _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[0];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_G_2_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[1];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[2];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4;
            float3 _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3;
            float2 _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2;
            Unity_Combine_float(_Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float, _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float, 0, 0, _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4, _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3, _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.tex, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.samplerstate, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.GetTransformedUV(_Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_G_6_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_B_7_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_A_8_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float;
            Unity_Branch_float(_Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean, _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float, 0, _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float;
            Unity_Absolute_float(_Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float, _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float;
            Unity_Power_float(_Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float, 2, _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float;
            Unity_Multiply_float_float(_Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float, _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float, _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[0];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_G_2_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[1];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[2];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_A_4_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2 = float2(_Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float, _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_3fc88fa712b44aeaab8f41107199bc74_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float;
            Unity_Subtract_float(_Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float;
            Unity_Clamp_float(_Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float, 0.0001, 1000, _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float;
            Unity_Divide_float(_Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float;
            Unity_Absolute_float(_Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float, _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float;
            Unity_Power_float(_Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float, _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float, _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float;
            Unity_Multiply_float_float(_Power_ad608225df654ce094ffb8b933e16525_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float;
            Unity_Absolute_float(_Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float, _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float;
            Unity_Power_float(_Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float, _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float, _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float;
            Unity_SquareRoot_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float;
            Unity_Multiply_float_float(_Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float;
            Unity_Branch_float(_Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float;
            Unity_Multiply_float_float(_Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2, (_Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float.xx), _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5093515884134bcb9155fab829022fce_R_1_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[0];
            float _Split_5093515884134bcb9155fab829022fce_G_2_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[1];
            float _Split_5093515884134bcb9155fab829022fce_B_3_Float = 0;
            float _Split_5093515884134bcb9155fab829022fce_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3 = float3(_Split_5093515884134bcb9155fab829022fce_R_1_Float, 0, _Split_5093515884134bcb9155fab829022fce_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float.xxx), _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3;
            Unity_Add_float3(_Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c9aaa3880e954454a02d36009c8e9e68_R_1_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[0];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_G_2_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[1];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_B_3_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[2];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3, (_Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float.xxx), _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3, _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3, (_Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float.xxx), _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[0];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_G_2_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[1];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[2];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4;
            float3 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3;
            float2 _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2;
            Unity_Combine_float(_Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float, _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float, 0, 0, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3, _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.tex, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.samplerstate, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.GetTransformedUV(_Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_A_8_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4;
            float3 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3;
            float2 _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float, 0, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3;
            Unity_Add_float3(_Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3, (_Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float.xxx), _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float;
            Unity_Multiply_float_float(_Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3, (_Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float.xxx), _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_b0b77f3ff3554aaa991ca36800c29365_R_1_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[0];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[1];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_B_3_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[2];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3;
            Unity_Add_float3(_Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean, _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3;
            Unity_Add_float3(_Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            Unity_Branch_float3(_Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3, _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3, _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            #else
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.Alpha_Dist = _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Alpha_Dist = input.Alpha_Dist;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4 = _Particle_Color_RGB_Alpha_A;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_R_1_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[0];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_G_2_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[1];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_B_3_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[2];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Color_Mask_R_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.tex, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.samplerstate, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.GetTransformedUV((_UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4.xy)) );
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_R_4_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_G_5_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_B_6_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float;
            Unity_Multiply_float_float(_Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float, _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float, _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float, _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float;
            surface.AlphaClipThreshold = _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Alpha_Dist = input.Alpha_Dist;
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.VertexColor = input.color;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ USE_TRANSPARENCY_INTERSECTION_ON
        #pragma shader_feature_local _ EMISSION_PROCEDURAL_MASK_ON
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 VertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 packed_positionWS_Alpha_Dist : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.packed_positionWS_Alpha_Dist.xyz = input.positionWS;
            output.packed_positionWS_Alpha_Dist.w = input.Alpha_Dist;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.packed_positionWS_Alpha_Dist.xyz;
            output.Alpha_Dist = input.packed_positionWS_Alpha_Dist.w;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Use_Scene_Light_s_Direction;
        float3 _Light_Direction;
        float _AlphaClipThreshold;
        float _Alpha_Multiplier;
        float4 _Normal_Map_TexelSize;
        float _Normal_Map_Light_Impact;
        float4 _Color_Mask_R_Emission_B_Transparency_A_TexelSize;
        float _Read_Color_Mask;
        float4 _Particle_Color_RGB_Alpha_A;
        float _Color_Blend;
        float _Light_Intensity;
        float _Light_Contrast;
        float _Light_Blend_Intensity;
        float4 _Light_Color;
        float4 _Shadow_Color;
        float4 _Emission_Gradient_TexelSize;
        float4 _Emission_Color;
        float _Emission_Over_Time;
        float _Emission_Gradient_Contrast;
        float _Emission_From_R_T_From_B_F;
        float _Intersection_Offset;
        float _CullingStart;
        float _CullingDistance;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Color_Mask_R_Emission_B_Transparency_A);
        SAMPLER(sampler_Color_Mask_R_Emission_B_Transparency_A);
        TEXTURE2D(_Emission_Gradient);
        SAMPLER(sampler_Emission_Gradient);
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustWorldScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Alpha_Dist;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float = _CullingDistance;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float = _CullingStart;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float;
            Unity_Subtract_float(_Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float, _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float, _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float;
            Unity_Divide_float(_Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float, _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float, _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            Unity_Saturate_float(_Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float, _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_46678044b69341a48cefb2cba33ed79a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_46678044b69341a48cefb2cba33ed79a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_46678044b69341a48cefb2cba33ed79a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_46678044b69341a48cefb2cba33ed79a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[0];
            float _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[1];
            float _Split_9fde5fb7f6864cefa72dada578d17557_B_3_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[2];
            float _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float;
            Unity_Multiply_float_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, 0.5, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float;
            Unity_Subtract_float(_Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_46678044b69341a48cefb2cba33ed79a_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float, 0, _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_169ba66547c24fa7a9cef296b67139b3_R_1_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[0];
            float _Split_169ba66547c24fa7a9cef296b67139b3_G_2_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[1];
            float _Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[2];
            float _Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float;
            Unity_Branch_float(_Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3 = float3(_Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3;
            _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3 = TransformObjectToWorld(_Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3, (_Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float.xxx), _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3, _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3, _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3, (_Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float.xxx), _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[0];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_G_2_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[1];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[2];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4;
            float3 _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3;
            float2 _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2;
            Unity_Combine_float(_Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float, _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float, 0, 0, _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4, _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3, _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.tex, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.samplerstate, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.GetTransformedUV(_Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_G_6_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_B_7_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_A_8_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float;
            Unity_Branch_float(_Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean, _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float, 0, _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float;
            Unity_Absolute_float(_Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float, _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float;
            Unity_Power_float(_Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float, 2, _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float;
            Unity_Multiply_float_float(_Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float, _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float, _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[0];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_G_2_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[1];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[2];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_A_4_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2 = float2(_Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float, _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_3fc88fa712b44aeaab8f41107199bc74_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float;
            Unity_Subtract_float(_Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float;
            Unity_Clamp_float(_Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float, 0.0001, 1000, _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float;
            Unity_Divide_float(_Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float;
            Unity_Absolute_float(_Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float, _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float;
            Unity_Power_float(_Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float, _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float, _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float;
            Unity_Multiply_float_float(_Power_ad608225df654ce094ffb8b933e16525_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float;
            Unity_Absolute_float(_Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float, _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float;
            Unity_Power_float(_Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float, _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float, _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float;
            Unity_SquareRoot_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float;
            Unity_Multiply_float_float(_Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float;
            Unity_Branch_float(_Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float;
            Unity_Multiply_float_float(_Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2, (_Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float.xx), _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5093515884134bcb9155fab829022fce_R_1_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[0];
            float _Split_5093515884134bcb9155fab829022fce_G_2_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[1];
            float _Split_5093515884134bcb9155fab829022fce_B_3_Float = 0;
            float _Split_5093515884134bcb9155fab829022fce_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3 = float3(_Split_5093515884134bcb9155fab829022fce_R_1_Float, 0, _Split_5093515884134bcb9155fab829022fce_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float.xxx), _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3;
            Unity_Add_float3(_Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c9aaa3880e954454a02d36009c8e9e68_R_1_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[0];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_G_2_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[1];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_B_3_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[2];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3, (_Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float.xxx), _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3, _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3, (_Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float.xxx), _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[0];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_G_2_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[1];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[2];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4;
            float3 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3;
            float2 _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2;
            Unity_Combine_float(_Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float, _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float, 0, 0, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3, _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.tex, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.samplerstate, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.GetTransformedUV(_Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_A_8_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4;
            float3 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3;
            float2 _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float, 0, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3;
            Unity_Add_float3(_Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3, (_Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float.xxx), _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float;
            Unity_Multiply_float_float(_Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3, (_Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float.xxx), _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_b0b77f3ff3554aaa991ca36800c29365_R_1_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[0];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[1];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_B_3_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[2];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3;
            Unity_Add_float3(_Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean, _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3;
            Unity_Add_float3(_Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            Unity_Branch_float3(_Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3, _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3, _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            #else
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.Alpha_Dist = _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Alpha_Dist = input.Alpha_Dist;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4 = _Particle_Color_RGB_Alpha_A;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_R_1_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[0];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_G_2_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[1];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_B_3_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[2];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Color_Mask_R_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.tex, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.samplerstate, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.GetTransformedUV((_UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4.xy)) );
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_R_4_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_G_5_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_B_6_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float;
            Unity_Multiply_float_float(_Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float, _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float, _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float, _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float;
            surface.AlphaClipThreshold = _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Alpha_Dist = input.Alpha_Dist;
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.VertexColor = input.color;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _ USE_TRANSPARENCY_INTERSECTION_ON
        #pragma shader_feature_local _ EMISSION_PROCEDURAL_MASK_ON
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(EMISSION_PROCEDURAL_MASK_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(EMISSION_PROCEDURAL_MASK_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 VertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float Alpha_Dist;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 packed_positionWS_Alpha_Dist : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.packed_positionWS_Alpha_Dist.xyz = input.positionWS;
            output.packed_positionWS_Alpha_Dist.w = input.Alpha_Dist;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.packed_positionWS_Alpha_Dist.xyz;
            output.Alpha_Dist = input.packed_positionWS_Alpha_Dist.w;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Use_Scene_Light_s_Direction;
        float3 _Light_Direction;
        float _AlphaClipThreshold;
        float _Alpha_Multiplier;
        float4 _Normal_Map_TexelSize;
        float _Normal_Map_Light_Impact;
        float4 _Color_Mask_R_Emission_B_Transparency_A_TexelSize;
        float _Read_Color_Mask;
        float4 _Particle_Color_RGB_Alpha_A;
        float _Color_Blend;
        float _Light_Intensity;
        float _Light_Contrast;
        float _Light_Blend_Intensity;
        float4 _Light_Color;
        float4 _Shadow_Color;
        float4 _Emission_Gradient_TexelSize;
        float4 _Emission_Color;
        float _Emission_Over_Time;
        float _Emission_Gradient_Contrast;
        float _Emission_From_R_T_From_B_F;
        float _Intersection_Offset;
        float _CullingStart;
        float _CullingDistance;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Color_Mask_R_Emission_B_Transparency_A);
        SAMPLER(sampler_Color_Mask_R_Emission_B_Transparency_A);
        TEXTURE2D(_Emission_Gradient);
        SAMPLER(sampler_Emission_Gradient);
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustWorldScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_SquareRoot_float(float In, out float Out)
        {
            Out = sqrt(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float Alpha_Dist;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float = _CullingDistance;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float = _CullingStart;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float;
            Unity_Subtract_float(_Distance_e80200b97b78ed80b5fc02aec8d2f2f6_Out_2_Float, _Property_6d5a545a1cef9b848c4a162895bc897a_Out_0_Float, _Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float;
            Unity_Divide_float(_Subtract_2c7b4ec5e800dd8cb3f7cef1d0414c42_Out_2_Float, _Property_4aaefb909df2fd80910a396d8c946d2a_Out_0_Float, _Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            Unity_Saturate_float(_Divide_be35fd951d1f1f859bf8c4d9b4e1ea83_Out_2_Float, _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_46678044b69341a48cefb2cba33ed79a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_46678044b69341a48cefb2cba33ed79a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_46678044b69341a48cefb2cba33ed79a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_46678044b69341a48cefb2cba33ed79a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[0];
            float _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[1];
            float _Split_9fde5fb7f6864cefa72dada578d17557_B_3_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[2];
            float _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float = _UV_2d492fc054304902b0151f7984595c42_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float;
            Unity_Multiply_float_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, 0.5, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float;
            Unity_Subtract_float(_Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Multiply_4b408c1a8d904c6caa134aa32fe4d296_Out_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_46678044b69341a48cefb2cba33ed79a_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_ff5f9e21fad34542be9f1b424842b5d5_Out_0_Float, 0, _Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_169ba66547c24fa7a9cef296b67139b3_R_1_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[0];
            float _Split_169ba66547c24fa7a9cef296b67139b3_G_2_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[1];
            float _Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[2];
            float _Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float = _UV_04a611f24d2742cb80edc56b692e1ffa_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float;
            Unity_Branch_float(_Property_d13cb597291d4f2a96775483a905e1bc_Out_0_Boolean, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_R_1_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3 = float3(_Split_169ba66547c24fa7a9cef296b67139b3_A_4_Float, _Branch_71e8eb49280e46aeae20fdae2f4bc348_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3;
            _Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3 = TransformObjectToWorld(_Vector3_7b042258827846d08e5f3cf44763b183_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_9c06780eae3f45a89550792b236e2910_Out_0_Vector3, (_Property_02bf9d8b187f4750a645a31fd0274ce4_Out_0_Float.xxx), _Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_fe6171f686004685a995362ecdec980a_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_fc1b57ebcbfc495c868a133d8c8cd769_Out_1_Vector3, _Multiply_5760387dae6a4323af5ae9022291bf5f_Out_2_Vector3, _Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b1a7ff37e6d249f6b46172441d2e19c2_Out_2_Vector3, (_Property_691e8ce713864fbb94a8b323f8fb183a_Out_0_Float.xxx), _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[0];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_G_2_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[1];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float = _Multiply_fb48cf32daac482ca1e0efd524ef7339_Out_2_Vector3[2];
            float _Split_2c42efceaee6419fa47ba9af29b833f5_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4;
            float3 _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3;
            float2 _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2;
            Unity_Combine_float(_Split_2c42efceaee6419fa47ba9af29b833f5_R_1_Float, _Split_2c42efceaee6419fa47ba9af29b833f5_B_3_Float, 0, 0, _Combine_1b3bce32ac0d41719a13050c50108c03_RGBA_4_Vector4, _Combine_1b3bce32ac0d41719a13050c50108c03_RGB_5_Vector3, _Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.tex, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.samplerstate, _Property_64ce982dd9ba445db803d190de84c8d6_Out_0_Texture2D.GetTransformedUV(_Combine_1b3bce32ac0d41719a13050c50108c03_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_G_6_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_B_7_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_A_8_Float = _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float;
            Unity_Branch_float(_Comparison_5a5e933a48a84ce0a554156d627555a1_Out_2_Boolean, _SampleTexture2DLOD_2ddf290f5cf648f0a5aee6429cd75373_R_5_Float, 0, _Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float;
            Unity_Absolute_float(_Branch_b236d2baf0314767b8cb611a3816d1e6_Out_3_Float, _Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float;
            Unity_Power_float(_Absolute_3ee727f339e1481fac857cee4e12e1dd_Out_1_Float, 2, _Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float;
            Unity_Multiply_float_float(_Power_5590fac6870f4a418050425dc7ed91c1_Out_2_Float, _Property_f14b1d29b26f41c296ed14cc4451462d_Out_0_Float, _Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[0];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_G_2_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[1];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[2];
            float _Split_ee9e31594b8f4517a17dfbbc48a64e32_A_4_Float = _Property_5f939790876c4391a5e6741ce49c14da_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2 = float2(_Split_ee9e31594b8f4517a17dfbbc48a64e32_R_1_Float, _Split_ee9e31594b8f4517a17dfbbc48a64e32_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_3fc88fa712b44aeaab8f41107199bc74_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_3fc88fa712b44aeaab8f41107199bc74_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float;
            Unity_Subtract_float(_Split_3fc88fa712b44aeaab8f41107199bc74_G_2_Float, _Subtract_78847c4d89294687ae6c680682470352_Out_2_Float, _Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float;
            Unity_Clamp_float(_Subtract_8404aef24ea3408789d0c0f51b96ef78_Out_2_Float, 0.0001, 1000, _Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float;
            Unity_Divide_float(_Clamp_761450e98ce74595a10c5d1c917cc3c9_Out_3_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float;
            Unity_Absolute_float(_Divide_3c6fe64dd18d4200baad0ac784339bbe_Out_2_Float, _Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float;
            Unity_Power_float(_Absolute_3f4d8cab96d545468d52fce113f76434_Out_1_Float, _Property_6e6db1c06c6c4a289c25a90afb702cd1_Out_0_Float, _Power_ad608225df654ce094ffb8b933e16525_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float;
            Unity_Multiply_float_float(_Power_ad608225df654ce094ffb8b933e16525_Out_2_Float, _Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float;
            Unity_Absolute_float(_Split_169ba66547c24fa7a9cef296b67139b3_B_3_Float, _Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float;
            Unity_Power_float(_Absolute_fe5bbeb261f14196a3c73be780f44b29_Out_1_Float, _Property_14ce10c8d74142fda9edaa63c78a1389_Out_0_Float, _Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float;
            Unity_SquareRoot_float(_Split_9fde5fb7f6864cefa72dada578d17557_A_4_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float;
            Unity_Multiply_float_float(_Power_548cb6e3ae7445c582c39188c47c5226_Out_2_Float, _SquareRoot_70a17436440d482687ba4143db66c309_Out_1_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float;
            Unity_Branch_float(_Property_3a3872bc9d9e40d6b74bc603a4a8a4c1_Out_0_Boolean, _Multiply_a642a06d7343425eab6e63dcd10e4908_Out_2_Float, _Multiply_1acffa8d10b64862953260bcd3d33970_Out_2_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float;
            Unity_Multiply_float_float(_Property_7215796a7b8d4fa8b266a2e0be08c36f_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_451793a5e94f4b218ef6520e26d7867c_Out_0_Vector2, (_Multiply_0f5677745e9c46fa9f2f2771d48244b3_Out_2_Float.xx), _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5093515884134bcb9155fab829022fce_R_1_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[0];
            float _Split_5093515884134bcb9155fab829022fce_G_2_Float = _Multiply_fdb2c346ba1d4c38bf87ca44201ad86f_Out_2_Vector2[1];
            float _Split_5093515884134bcb9155fab829022fce_B_3_Float = 0;
            float _Split_5093515884134bcb9155fab829022fce_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3 = float3(_Split_5093515884134bcb9155fab829022fce_R_1_Float, 0, _Split_5093515884134bcb9155fab829022fce_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_359fe7d7086f47218f5dd1f02560916b_Out_2_Float.xxx), _Vector3_f29334ed9daa46d486b2377b0162c627_Out_0_Vector3, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3;
            Unity_Add_float3(_Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c9aaa3880e954454a02d36009c8e9e68_R_1_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[0];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_G_2_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[1];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_B_3_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[2];
            float _Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float = _Property_2035c69c7a3e4f2c94275ccbd5c13cd7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_985be46ae02c42c0995d1366bdbfb682_Out_0_Vector3, (_Split_c9aaa3880e954454a02d36009c8e9e68_A_4_Float.xxx), _Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_f9494d6eaf7949daa18912be3f0f987e_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_98e816e9ad134e1a8a9b20bd2c5e73a8_Out_2_Vector3, _Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f2e2ef6313b44230a3db59fa292116b9_Out_2_Vector3, (_Property_d4e06cbed31a4a3f9b43d0ecf16fcb73_Out_0_Float.xxx), _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[0];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_G_2_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[1];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float = _Multiply_54e7c7ece7a14e578920ee4fca229293_Out_2_Vector3[2];
            float _Split_03b56eed62bc4b0e8cd4670fc93a9da4_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4;
            float3 _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3;
            float2 _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2;
            Unity_Combine_float(_Split_03b56eed62bc4b0e8cd4670fc93a9da4_R_1_Float, _Split_03b56eed62bc4b0e8cd4670fc93a9da4_B_3_Float, 0, 0, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGBA_4_Vector4, _Combine_fca4aa581e8a422dadf8e319f06750f7_RGB_5_Vector3, _Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.tex, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.samplerstate, _Property_e70a0a7f80a1411a8dc51ae03c2ae95e_Out_0_Texture2D.GetTransformedUV(_Combine_fca4aa581e8a422dadf8e319f06750f7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_A_8_Float = _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4;
            float3 _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3;
            float2 _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_R_5_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_G_6_Float, _SampleTexture2DLOD_42f419ca99f74153a9ee1ff31ce6633c_B_7_Float, 0, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGBA_4_Vector4, _Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, _Combine_fa07fd2270a34c469cf64b3454d120aa_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3;
            Unity_Add_float3(_Combine_fa07fd2270a34c469cf64b3454d120aa_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_5ecb9bb08cf149b78d7ee84e95bf3643_Out_2_Vector3, (_Property_aa970d7a10da4334a2114ceba6cb2ad7_Out_0_Float.xxx), _Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float;
            Unity_Multiply_float_float(_Property_b8009b443755414084f8b9a8c5df13f8_Out_0_Float, _Branch_714a0819ec464e2a9d966e02047cb9b5_Out_3_Float, _Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_5dd52750c8794f1590124b29e1a62761_Out_2_Vector3, (_Multiply_80f6cf8730524551ba9e500666d243db_Out_2_Float.xxx), _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_b0b77f3ff3554aaa991ca36800c29365_R_1_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[0];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[1];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_B_3_Float = _Multiply_64d19ba4a3a0487392d8b263295c959d_Out_2_Vector3[2];
            float _Split_b0b77f3ff3554aaa991ca36800c29365_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3;
            Unity_Add_float3(_Add_3867aafb9ad34746bce1244aafb6f01f_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_01febf46ca4548908ecc25ab6a83d355_Out_2_Boolean, _Add_390c742d4a2a46e288eef208355b690b_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_88ef96fe582c4d6b82162ac0c9c74ae3_Out_2_Vector3, _Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3;
            Unity_Add_float3(_Add_4a6e9e743bca419f8339e6bf6909217a_Out_2_Vector3, (_Split_b0b77f3ff3554aaa991ca36800c29365_G_2_Float.xxx), _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            Unity_Branch_float3(_Property_dc33bb4f88f642af9e0aa9ed9bd30981_Out_0_Boolean, _Branch_0e5e503876e64025b3fd5b47d646900e_Out_3_Vector3, _Add_e58b3adc54484db98b10cc7c5c7a4ccc_Out_2_Vector3, _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = _Branch_391d7aed55d14db9bc9006f538ed0f37_Out_3_Vector3;
            #else
            float3 _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2f64fa5d3de94730954a4455b8c92bfd_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.Alpha_Dist = _Saturate_535c22048a33c881891d7ed64f9c4d9c_Out_1_Float;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Alpha_Dist = input.Alpha_Dist;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4 = _Particle_Color_RGB_Alpha_A;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_R_1_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[0];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_G_2_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[1];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_B_3_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[2];
            float _Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float = _Property_b7fc7bb7e8ed2c8da6489b6d9d78d3f7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Color_Mask_R_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.tex, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.samplerstate, _Property_b09a268918324309a33891087641d2aa_Out_0_Texture2D.GetTransformedUV((_UV_d44465d44af04fd8b715e551588121fe_Out_0_Vector4.xy)) );
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_R_4_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_G_5_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_B_6_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float = _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float;
            Unity_Multiply_float_float(_Split_4d25adc154b2cd889bea31041dc0b8bd_A_4_Float, _SampleTexture2D_185b79e27fa17080b89730ca7c4303ce_A_7_Float, _Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_8924d386398049b1b9840fa123d39092_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_adbe396b9120628ea1a79eee1222a007_Out_2_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_fce3e00b583f4272a2ffa6b9e2fe3340_Out_0_Float, _Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_a2f35ebf0efb49d6b79c69656b61fba2_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_b049cb5c0a2649839eed4a9b6f843b0d_Out_0_Float;
            surface.AlphaClipThreshold = _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            output.Alpha_Dist = input.Alpha_Dist;
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.VertexColor = input.color;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}