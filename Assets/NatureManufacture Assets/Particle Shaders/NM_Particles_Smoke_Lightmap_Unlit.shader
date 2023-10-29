Shader "NatureManufacture/URP/Particles/Smoke Lightmap Unlit"
{
    Properties
    {
        [ToggleUI]_Use_Scene_Light_s_Direction("Use Scene Light's Direction", Float) = 1
        _Light_Direction("Light Direction", Vector) = (0, 0, 0, 0)
        _AlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 1
        _Alpha_Multiplier("Alpha Multiplier", Float) = 1
        [NoScaleOffset]_Lightmap_Right_R_Left_G_Top_B_Bottom_A("Lightmap Right(R) Left(G) Top(B) Bottom(A)", 2D) = "white" {}
        [NoScaleOffset]_Lightmap_Front_R_Back_G_Emission_B_Transparency_A("Lightmap Front(R) Back(G) Emission(B) Transparency(A)", 2D) = "white" {}
        _Light_Intensity("Light Intensity", Float) = 1
        _Light_Contrast("Light Contrast", Float) = 1
        _Light_Blend_Intensity("Light Blend Intensity", Float) = 1
        _Light_Color("Light Color", Color) = (1, 1, 1, 0)
        _Shadow_Color("Shadow Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_Emission_Gradient("Emission Gradient", 2D) = "white" {}
        [HDR]_Emission_Color("Emission Color", Color) = (0, 0, 0, 0)
        _Emission_Over_Time("Emission Over Time", Float) = 1
        _Emission_Gradient_Contrast("Emission Gradient Contrast", Float) = 1.5
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
        [HideInInspector]_CastShadows("_CastShadows", Float) = 0
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
             float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 WorldSpaceTangent;
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
        float4 _Lightmap_Right_R_Left_G_Top_B_Bottom_A_TexelSize;
        float4 _Lightmap_Front_R_Back_G_Emission_B_Transparency_A_TexelSize;
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
        TEXTURE2D(_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        SAMPLER(sampler_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        TEXTURE2D(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
        SAMPLER(sampler_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
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
            float _Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_51e86316bdbf41249868945a9b6b9a4c_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[0];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[1];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_B_3_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[2];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float;
            Unity_Multiply_float_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, 0.5, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float;
            Unity_Subtract_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float, 0, _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_R_1_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[0];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_G_2_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[1];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[2];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_999d092efd29405dbd949541922cda73_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float;
            Unity_Branch_float(_Property_999d092efd29405dbd949541922cda73_Out_0_Boolean, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3 = float3(_Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3;
            _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3 = TransformObjectToWorld(_Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3, (_Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float.xxx), _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3, _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3, _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3, (_Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float.xxx), _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[0];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_G_2_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[1];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[2];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4;
            float3 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3;
            float2 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2;
            Unity_Combine_float(_Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float, _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float, 0, 0, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.tex, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.samplerstate, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.GetTransformedUV(_Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_G_6_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_B_7_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_A_8_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float;
            Unity_Branch_float(_Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean, _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float, 0, _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float;
            Unity_Absolute_float(_Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float, _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float;
            Unity_Power_float(_Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float, 2, _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float;
            Unity_Multiply_float_float(_Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float, _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float, _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[0];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_G_2_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[1];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[2];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_A_4_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2 = float2(_Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float, _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_8c455b935021482ab84f271349aa08d0_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float;
            Unity_Subtract_float(_Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float;
            Unity_Clamp_float(_Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float, 0.0001, 1000, _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float;
            Unity_Divide_float(_Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float;
            Unity_Absolute_float(_Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float, _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float;
            Unity_Power_float(_Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float, _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float, _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float;
            Unity_Multiply_float_float(_Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float;
            Unity_Absolute_float(_Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float, _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float;
            Unity_Power_float(_Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float, _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float, _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float;
            Unity_SquareRoot_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float;
            Unity_Multiply_float_float(_Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float;
            Unity_Branch_float(_Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float;
            Unity_Multiply_float_float(_Property_8c455b935021482ab84f271349aa08d0_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2, (_Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float.xx), _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[0];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[1];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_B_3_Float = 0;
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3 = float3(_Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float, 0, _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float.xxx), _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3;
            Unity_Add_float3(_Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_R_1_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[0];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_G_2_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[1];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_B_3_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[2];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3, (_Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float.xxx), _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3, _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3, (_Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float.xxx), _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[0];
            float _Split_9a881e39bf104d84a60a7983a19fb133_G_2_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[1];
            float _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[2];
            float _Split_9a881e39bf104d84a60a7983a19fb133_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4;
            float3 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3;
            float2 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2;
            Unity_Combine_float(_Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float, _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float, 0, 0, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.tex, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.samplerstate, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.GetTransformedUV(_Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_A_8_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4;
            float3 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3;
            float2 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float, 0, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3;
            Unity_Add_float3(_Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3, (_Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float.xxx), _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3, (_Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float.xxx), _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_30d6dc8961c547bdb8666410203ec212_R_1_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[0];
            float _Split_30d6dc8961c547bdb8666410203ec212_G_2_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[1];
            float _Split_30d6dc8961c547bdb8666410203ec212_B_3_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[2];
            float _Split_30d6dc8961c547bdb8666410203ec212_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3;
            Unity_Add_float3(_Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean, _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3;
            Unity_Add_float3(_Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            Unity_Branch_float3(_Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3, _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3, _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            #else
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3;
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
            float4 _Property_f36be38917b84145bed1ee5473ab7b71_Out_0_Vector4 = _Light_Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_LightDataURP_a02ff11a29d676645b44ec159fdb9001_float _LightDataURP_fee142b27c0e49a59bf2f228c65207f3;
            float3 _LightDataURP_fee142b27c0e49a59bf2f228c65207f3_Direction_1_Vector3;
            float3 _LightDataURP_fee142b27c0e49a59bf2f228c65207f3_Color_2_Vector3;
            SG_LightDataURP_a02ff11a29d676645b44ec159fdb9001_float(_LightDataURP_fee142b27c0e49a59bf2f228c65207f3, _LightDataURP_fee142b27c0e49a59bf2f228c65207f3_Direction_1_Vector3, _LightDataURP_fee142b27c0e49a59bf2f228c65207f3_Color_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Normalize_cab2cd9071ba47daa88f041b3adeda24_Out_1_Vector3;
            Unity_Normalize_float3(_LightDataURP_fee142b27c0e49a59bf2f228c65207f3_Color_2_Vector3, _Normalize_cab2cd9071ba47daa88f041b3adeda24_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5e296dcc21ab44c3bb63687cb9daffae_Out_0_Float = _Light_Blend_Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Lerp_1cd2e858c3344279825417a915c5f3c1_Out_3_Vector3;
            Unity_Lerp_float3((_Property_f36be38917b84145bed1ee5473ab7b71_Out_0_Vector4.xyz), _Normalize_cab2cd9071ba47daa88f041b3adeda24_Out_1_Vector3, (_Property_5e296dcc21ab44c3bb63687cb9daffae_Out_0_Float.xxx), _Lerp_1cd2e858c3344279825417a915c5f3c1_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_79dccbe78c394034b0b4cc01e634562f_Out_0_Float = _Light_Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f30be5b7959f4ea4a523a87fa1dbdb30_Out_0_Boolean = _Use_Scene_Light_s_Direction;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Property_a655206fed7a48f8a7389ef07726533a_Out_0_Vector3 = _Light_Direction;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_e3c49d7c27aa4930a2870784bb46bd22_Out_3_Vector3;
            Unity_Branch_float3(_Property_f30be5b7959f4ea4a523a87fa1dbdb30_Out_0_Boolean, _LightDataURP_fee142b27c0e49a59bf2f228c65207f3_Direction_1_Vector3, _Property_a655206fed7a48f8a7389ef07726533a_Out_0_Vector3, _Branch_e3c49d7c27aa4930a2870784bb46bd22_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_ce2db4521b274f2a9f4e6c66e36d92dc_Out_1_Vector3;
            {
                float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                _Transform_ce2db4521b274f2a9f4e6c66e36d92dc_Out_1_Vector3 = TransformWorldToTangentDir(_Branch_e3c49d7c27aa4930a2870784bb46bd22_Out_3_Vector3.xyz, tangentTransform, true);
            }
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_2fcede9d28db473d8e0729c71a5d378e_R_1_Float = _Transform_ce2db4521b274f2a9f4e6c66e36d92dc_Out_1_Vector3[0];
            float _Split_2fcede9d28db473d8e0729c71a5d378e_G_2_Float = _Transform_ce2db4521b274f2a9f4e6c66e36d92dc_Out_1_Vector3[1];
            float _Split_2fcede9d28db473d8e0729c71a5d378e_B_3_Float = _Transform_ce2db4521b274f2a9f4e6c66e36d92dc_Out_1_Vector3[2];
            float _Split_2fcede9d28db473d8e0729c71a5d378e_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a2a6f6bf86e242799c65fe5336ef2085_Out_2_Float;
            Unity_Multiply_float_float(_Split_2fcede9d28db473d8e0729c71a5d378e_R_1_Float, _Split_2fcede9d28db473d8e0729c71a5d378e_R_1_Float, _Multiply_a2a6f6bf86e242799c65fe5336ef2085_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_66df299800b54ad3be734b643a4805e3_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_2fcede9d28db473d8e0729c71a5d378e_R_1_Float, 0, _Comparison_66df299800b54ad3be734b643a4805e3_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_15b7a6edba0e434d8ae14daa3624e922_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_15b7a6edba0e434d8ae14daa3624e922_Out_0_Texture2D.tex, _Property_15b7a6edba0e434d8ae14daa3624e922_Out_0_Texture2D.samplerstate, _Property_15b7a6edba0e434d8ae14daa3624e922_Out_0_Texture2D.GetTransformedUV((_UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4.xy)) );
            float _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_R_4_Float = _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_RGBA_0_Vector4.r;
            float _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_G_5_Float = _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_RGBA_0_Vector4.g;
            float _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_B_6_Float = _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_RGBA_0_Vector4.b;
            float _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_A_7_Float = _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b39199aa9c734d3ab8d25901c4cfc4e2_Out_3_Float;
            Unity_Branch_float(_Comparison_66df299800b54ad3be734b643a4805e3_Out_2_Boolean, _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_R_4_Float, _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_G_5_Float, _Branch_b39199aa9c734d3ab8d25901c4cfc4e2_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_d7ebb2ee1ed1486587fbb1db66b9f5e5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_a2a6f6bf86e242799c65fe5336ef2085_Out_2_Float, _Branch_b39199aa9c734d3ab8d25901c4cfc4e2_Out_3_Float, _Multiply_d7ebb2ee1ed1486587fbb1db66b9f5e5_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_09432e5cae674c4ba0fbfb92c4550a95_Out_2_Float;
            Unity_Multiply_float_float(_Split_2fcede9d28db473d8e0729c71a5d378e_G_2_Float, _Split_2fcede9d28db473d8e0729c71a5d378e_G_2_Float, _Multiply_09432e5cae674c4ba0fbfb92c4550a95_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_cdf630aaba704a9992329d2c9fca39f2_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_2fcede9d28db473d8e0729c71a5d378e_G_2_Float, 0, _Comparison_cdf630aaba704a9992329d2c9fca39f2_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_7d4202b94870423993ee30d029a0a8fb_Out_3_Float;
            Unity_Branch_float(_Comparison_cdf630aaba704a9992329d2c9fca39f2_Out_2_Boolean, _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_B_6_Float, _SampleTexture2D_cff92ff2088a42bfa2e232e638fe10b0_A_7_Float, _Branch_7d4202b94870423993ee30d029a0a8fb_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_3fb94a4ebd1040428b9ca1162aac921b_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_09432e5cae674c4ba0fbfb92c4550a95_Out_2_Float, _Branch_7d4202b94870423993ee30d029a0a8fb_Out_3_Float, _Multiply_3fb94a4ebd1040428b9ca1162aac921b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_f8c9390adefe4d6eaf4cd072209cf0f4_Out_2_Float;
            Unity_Add_float(_Multiply_d7ebb2ee1ed1486587fbb1db66b9f5e5_Out_2_Float, _Multiply_3fb94a4ebd1040428b9ca1162aac921b_Out_2_Float, _Add_f8c9390adefe4d6eaf4cd072209cf0f4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_d064b865702347c7bf9087092aab9600_Out_2_Float;
            Unity_Multiply_float_float(_Split_2fcede9d28db473d8e0729c71a5d378e_B_3_Float, _Split_2fcede9d28db473d8e0729c71a5d378e_B_3_Float, _Multiply_d064b865702347c7bf9087092aab9600_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_64b2b2f5c4404d05b48d57851f1f2d03_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_2fcede9d28db473d8e0729c71a5d378e_B_3_Float, 0, _Comparison_64b2b2f5c4404d05b48d57851f1f2d03_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.tex, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.samplerstate, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.GetTransformedUV((_UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4.xy)) );
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_R_4_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.r;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_G_5_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.g;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_B_6_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.b;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_64602f21b9c9416da1dfec2d3d2e84a7_Out_3_Float;
            Unity_Branch_float(_Comparison_64b2b2f5c4404d05b48d57851f1f2d03_Out_2_Boolean, _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_R_4_Float, _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_G_5_Float, _Branch_64602f21b9c9416da1dfec2d3d2e84a7_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_124a1b3518c344eba646b1bc24eee3e6_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_d064b865702347c7bf9087092aab9600_Out_2_Float, _Branch_64602f21b9c9416da1dfec2d3d2e84a7_Out_3_Float, _Multiply_124a1b3518c344eba646b1bc24eee3e6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_7032681b89f84db593d69f93a45bbc75_Out_2_Float;
            Unity_Add_float(_Add_f8c9390adefe4d6eaf4cd072209cf0f4_Out_2_Float, _Multiply_124a1b3518c344eba646b1bc24eee3e6_Out_2_Float, _Add_7032681b89f84db593d69f93a45bbc75_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e3efc137646d4f8589e2cf52ecdbc776_Out_0_Float = _Light_Contrast;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Contrast_6101616a60da488b9cb284133887df4d_Out_2_Vector3;
            Unity_Contrast_float((_Add_7032681b89f84db593d69f93a45bbc75_Out_2_Float.xxx), _Property_e3efc137646d4f8589e2cf52ecdbc776_Out_0_Float, _Contrast_6101616a60da488b9cb284133887df4d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_15ce2c7715b84038b6f62a4cd89fb9a3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_79dccbe78c394034b0b4cc01e634562f_Out_0_Float.xxx), _Contrast_6101616a60da488b9cb284133887df4d_Out_2_Vector3, _Multiply_15ce2c7715b84038b6f62a4cd89fb9a3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_546eb10e1fef4b1b8ffa70f63cd8d2ed_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Lerp_1cd2e858c3344279825417a915c5f3c1_Out_3_Vector3, _Multiply_15ce2c7715b84038b6f62a4cd89fb9a3_Out_2_Vector3, _Multiply_546eb10e1fef4b1b8ffa70f63cd8d2ed_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_cc98f26cad4141a68ff5841f1f5e17ff_Out_0_Vector4 = _Shadow_Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_ecf29a72d29a4a23bccefd0508a65836_Out_2_Vector3;
            Unity_Add_float3(_Multiply_546eb10e1fef4b1b8ffa70f63cd8d2ed_Out_2_Vector3, (_Property_cc98f26cad4141a68ff5841f1f5e17ff_Out_0_Vector4.xyz), _Add_ecf29a72d29a4a23bccefd0508a65836_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_51095276272542988663e3a4e257a421_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_ecf29a72d29a4a23bccefd0508a65836_Out_2_Vector3, (_Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4.xyz), _Multiply_51095276272542988663e3a4e257a421_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_2ef9cd5c234c4b709d4be1c535dbb8e2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emission_Gradient);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_b77cb1c5719c41a8b224c185731c674b_Out_0_Vector2 = float2(_Add_7032681b89f84db593d69f93a45bbc75_Out_2_Float, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_27b28c49250a483da04beb787e0508b4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2ef9cd5c234c4b709d4be1c535dbb8e2_Out_0_Texture2D.tex, _Property_2ef9cd5c234c4b709d4be1c535dbb8e2_Out_0_Texture2D.samplerstate, _Property_2ef9cd5c234c4b709d4be1c535dbb8e2_Out_0_Texture2D.GetTransformedUV(_Vector2_b77cb1c5719c41a8b224c185731c674b_Out_0_Vector2) );
            float _SampleTexture2D_27b28c49250a483da04beb787e0508b4_R_4_Float = _SampleTexture2D_27b28c49250a483da04beb787e0508b4_RGBA_0_Vector4.r;
            float _SampleTexture2D_27b28c49250a483da04beb787e0508b4_G_5_Float = _SampleTexture2D_27b28c49250a483da04beb787e0508b4_RGBA_0_Vector4.g;
            float _SampleTexture2D_27b28c49250a483da04beb787e0508b4_B_6_Float = _SampleTexture2D_27b28c49250a483da04beb787e0508b4_RGBA_0_Vector4.b;
            float _SampleTexture2D_27b28c49250a483da04beb787e0508b4_A_7_Float = _SampleTexture2D_27b28c49250a483da04beb787e0508b4_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_96edaafb926e49a5bf0194ffbfd82b3d_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Emission_Color) : _Emission_Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_e65b2df8c62b410cb47c034e5a175d9c_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_27b28c49250a483da04beb787e0508b4_RGBA_0_Vector4, _Property_96edaafb926e49a5bf0194ffbfd82b3d_Out_0_Vector4, _Multiply_e65b2df8c62b410cb47c034e5a175d9c_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_d0347523aa664a99aaddb8e2b2cf096e_R_1_Float = _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4[0];
            float _Split_d0347523aa664a99aaddb8e2b2cf096e_G_2_Float = _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4[1];
            float _Split_d0347523aa664a99aaddb8e2b2cf096e_B_3_Float = _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4[2];
            float _Split_d0347523aa664a99aaddb8e2b2cf096e_A_4_Float = _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4bd8db96283c4e6f91c7009cfa1b75ca_Out_0_Float = _Emission_Gradient_Contrast;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_d8df74081ea64320810b217ebb5189f1_Out_2_Float;
            Unity_Multiply_float_float(_Split_d0347523aa664a99aaddb8e2b2cf096e_B_3_Float, _Property_4bd8db96283c4e6f91c7009cfa1b75ca_Out_0_Float, _Multiply_d8df74081ea64320810b217ebb5189f1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_67f352c58dd14d39b00bdf29ee05c98b_Out_0_Float = _Emission_Over_Time;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_fa399e5c59604818ae01e3c374c78b04_Out_2_Float;
            Unity_Subtract_float(_Multiply_d8df74081ea64320810b217ebb5189f1_Out_2_Float, _Property_67f352c58dd14d39b00bdf29ee05c98b_Out_0_Float, _Subtract_fa399e5c59604818ae01e3c374c78b04_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_abfcd5a48d014313b92085f6e5c37a8b_Out_2_Float;
            Unity_Power_float(_Subtract_fa399e5c59604818ae01e3c374c78b04_Out_2_Float, 3, _Power_abfcd5a48d014313b92085f6e5c37a8b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6c61f469abf8482c90d9882b6ca81a03_Out_2_Float;
            Unity_Multiply_float_float(_Power_abfcd5a48d014313b92085f6e5c37a8b_Out_2_Float, -1, _Multiply_6c61f469abf8482c90d9882b6ca81a03_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Saturate_4a03682224b94f77b1b16c9e5f223ad9_Out_1_Float;
            Unity_Saturate_float(_Multiply_6c61f469abf8482c90d9882b6ca81a03_Out_2_Float, _Saturate_4a03682224b94f77b1b16c9e5f223ad9_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_ccfd3cf651eb408e8cdfb05319218c8a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_e65b2df8c62b410cb47c034e5a175d9c_Out_2_Vector4, (_Saturate_4a03682224b94f77b1b16c9e5f223ad9_Out_1_Float.xxxx), _Multiply_ccfd3cf651eb408e8cdfb05319218c8a_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5256630a31ea4932a8251e3137938dd9_Out_0_Boolean = _Emission_From_R_T_From_B_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_5161f635a35a4fdfb7bd85b27de9cbae_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_R_4_Float, _OneMinus_5161f635a35a4fdfb7bd85b27de9cbae_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_8698090152be4a9696447bb173b62373_Out_3_Float;
            Unity_Branch_float(_Property_5256630a31ea4932a8251e3137938dd9_Out_0_Boolean, _OneMinus_5161f635a35a4fdfb7bd85b27de9cbae_Out_1_Float, _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_B_6_Float, _Branch_8698090152be4a9696447bb173b62373_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a88f627ab45b48dcb31eabb7c2eb35ce_Out_2_Float;
            Unity_Multiply_float_float(_Branch_8698090152be4a9696447bb173b62373_Out_3_Float, _Saturate_4a03682224b94f77b1b16c9e5f223ad9_Out_1_Float, _Multiply_a88f627ab45b48dcb31eabb7c2eb35ce_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_5ee94c9b787544d6b653c953faec131c_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_96edaafb926e49a5bf0194ffbfd82b3d_Out_0_Vector4, (_Multiply_a88f627ab45b48dcb31eabb7c2eb35ce_Out_2_Float.xxxx), _Multiply_5ee94c9b787544d6b653c953faec131c_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(EMISSION_PROCEDURAL_MASK_ON)
            float4 _EmissionProceduralTMaskF_025b3ebde4744890972d49d66ac5e1e5_Out_0_Vector4 = _Multiply_ccfd3cf651eb408e8cdfb05319218c8a_Out_2_Vector4;
            #else
            float4 _EmissionProceduralTMaskF_025b3ebde4744890972d49d66ac5e1e5_Out_0_Vector4 = _Multiply_5ee94c9b787544d6b653c953faec131c_Out_2_Vector4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_15091a81455c464ba838ece217d9fad5_Out_2_Vector3;
            Unity_Add_float3(_Multiply_51095276272542988663e3a4e257a421_Out_2_Vector3, (_EmissionProceduralTMaskF_025b3ebde4744890972d49d66ac5e1e5_Out_0_Vector4.xyz), _Add_15091a81455c464ba838ece217d9fad5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float, _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
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
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.BaseColor = _Add_15091a81455c464ba838ece217d9fad5_Out_2_Vector3;
            surface.Alpha = _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float;
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
        float4 _Lightmap_Right_R_Left_G_Top_B_Bottom_A_TexelSize;
        float4 _Lightmap_Front_R_Back_G_Emission_B_Transparency_A_TexelSize;
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
        TEXTURE2D(_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        SAMPLER(sampler_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        TEXTURE2D(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
        SAMPLER(sampler_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
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
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_51e86316bdbf41249868945a9b6b9a4c_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[0];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[1];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_B_3_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[2];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float;
            Unity_Multiply_float_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, 0.5, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float;
            Unity_Subtract_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float, 0, _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_R_1_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[0];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_G_2_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[1];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[2];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_999d092efd29405dbd949541922cda73_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float;
            Unity_Branch_float(_Property_999d092efd29405dbd949541922cda73_Out_0_Boolean, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3 = float3(_Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3;
            _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3 = TransformObjectToWorld(_Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3, (_Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float.xxx), _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3, _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3, _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3, (_Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float.xxx), _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[0];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_G_2_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[1];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[2];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4;
            float3 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3;
            float2 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2;
            Unity_Combine_float(_Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float, _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float, 0, 0, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.tex, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.samplerstate, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.GetTransformedUV(_Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_G_6_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_B_7_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_A_8_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float;
            Unity_Branch_float(_Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean, _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float, 0, _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float;
            Unity_Absolute_float(_Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float, _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float;
            Unity_Power_float(_Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float, 2, _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float;
            Unity_Multiply_float_float(_Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float, _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float, _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[0];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_G_2_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[1];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[2];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_A_4_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2 = float2(_Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float, _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_8c455b935021482ab84f271349aa08d0_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float;
            Unity_Subtract_float(_Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float;
            Unity_Clamp_float(_Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float, 0.0001, 1000, _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float;
            Unity_Divide_float(_Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float;
            Unity_Absolute_float(_Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float, _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float;
            Unity_Power_float(_Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float, _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float, _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float;
            Unity_Multiply_float_float(_Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float;
            Unity_Absolute_float(_Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float, _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float;
            Unity_Power_float(_Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float, _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float, _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float;
            Unity_SquareRoot_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float;
            Unity_Multiply_float_float(_Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float;
            Unity_Branch_float(_Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float;
            Unity_Multiply_float_float(_Property_8c455b935021482ab84f271349aa08d0_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2, (_Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float.xx), _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[0];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[1];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_B_3_Float = 0;
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3 = float3(_Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float, 0, _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float.xxx), _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3;
            Unity_Add_float3(_Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_R_1_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[0];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_G_2_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[1];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_B_3_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[2];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3, (_Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float.xxx), _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3, _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3, (_Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float.xxx), _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[0];
            float _Split_9a881e39bf104d84a60a7983a19fb133_G_2_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[1];
            float _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[2];
            float _Split_9a881e39bf104d84a60a7983a19fb133_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4;
            float3 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3;
            float2 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2;
            Unity_Combine_float(_Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float, _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float, 0, 0, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.tex, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.samplerstate, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.GetTransformedUV(_Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_A_8_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4;
            float3 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3;
            float2 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float, 0, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3;
            Unity_Add_float3(_Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3, (_Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float.xxx), _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3, (_Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float.xxx), _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_30d6dc8961c547bdb8666410203ec212_R_1_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[0];
            float _Split_30d6dc8961c547bdb8666410203ec212_G_2_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[1];
            float _Split_30d6dc8961c547bdb8666410203ec212_B_3_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[2];
            float _Split_30d6dc8961c547bdb8666410203ec212_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3;
            Unity_Add_float3(_Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean, _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3;
            Unity_Add_float3(_Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            Unity_Branch_float3(_Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3, _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3, _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            #else
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3;
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
            UnityTexture2D _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.tex, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.samplerstate, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.GetTransformedUV((_UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4.xy)) );
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_R_4_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.r;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_G_5_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.g;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_B_6_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.b;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float, _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
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
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float;
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
        float4 _Lightmap_Right_R_Left_G_Top_B_Bottom_A_TexelSize;
        float4 _Lightmap_Front_R_Back_G_Emission_B_Transparency_A_TexelSize;
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
        TEXTURE2D(_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        SAMPLER(sampler_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        TEXTURE2D(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
        SAMPLER(sampler_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
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
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_51e86316bdbf41249868945a9b6b9a4c_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[0];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[1];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_B_3_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[2];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float;
            Unity_Multiply_float_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, 0.5, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float;
            Unity_Subtract_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float, 0, _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_R_1_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[0];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_G_2_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[1];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[2];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_999d092efd29405dbd949541922cda73_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float;
            Unity_Branch_float(_Property_999d092efd29405dbd949541922cda73_Out_0_Boolean, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3 = float3(_Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3;
            _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3 = TransformObjectToWorld(_Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3, (_Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float.xxx), _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3, _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3, _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3, (_Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float.xxx), _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[0];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_G_2_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[1];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[2];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4;
            float3 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3;
            float2 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2;
            Unity_Combine_float(_Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float, _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float, 0, 0, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.tex, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.samplerstate, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.GetTransformedUV(_Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_G_6_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_B_7_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_A_8_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float;
            Unity_Branch_float(_Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean, _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float, 0, _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float;
            Unity_Absolute_float(_Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float, _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float;
            Unity_Power_float(_Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float, 2, _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float;
            Unity_Multiply_float_float(_Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float, _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float, _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[0];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_G_2_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[1];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[2];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_A_4_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2 = float2(_Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float, _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_8c455b935021482ab84f271349aa08d0_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float;
            Unity_Subtract_float(_Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float;
            Unity_Clamp_float(_Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float, 0.0001, 1000, _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float;
            Unity_Divide_float(_Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float;
            Unity_Absolute_float(_Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float, _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float;
            Unity_Power_float(_Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float, _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float, _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float;
            Unity_Multiply_float_float(_Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float;
            Unity_Absolute_float(_Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float, _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float;
            Unity_Power_float(_Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float, _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float, _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float;
            Unity_SquareRoot_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float;
            Unity_Multiply_float_float(_Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float;
            Unity_Branch_float(_Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float;
            Unity_Multiply_float_float(_Property_8c455b935021482ab84f271349aa08d0_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2, (_Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float.xx), _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[0];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[1];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_B_3_Float = 0;
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3 = float3(_Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float, 0, _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float.xxx), _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3;
            Unity_Add_float3(_Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_R_1_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[0];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_G_2_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[1];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_B_3_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[2];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3, (_Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float.xxx), _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3, _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3, (_Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float.xxx), _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[0];
            float _Split_9a881e39bf104d84a60a7983a19fb133_G_2_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[1];
            float _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[2];
            float _Split_9a881e39bf104d84a60a7983a19fb133_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4;
            float3 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3;
            float2 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2;
            Unity_Combine_float(_Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float, _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float, 0, 0, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.tex, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.samplerstate, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.GetTransformedUV(_Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_A_8_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4;
            float3 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3;
            float2 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float, 0, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3;
            Unity_Add_float3(_Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3, (_Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float.xxx), _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3, (_Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float.xxx), _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_30d6dc8961c547bdb8666410203ec212_R_1_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[0];
            float _Split_30d6dc8961c547bdb8666410203ec212_G_2_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[1];
            float _Split_30d6dc8961c547bdb8666410203ec212_B_3_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[2];
            float _Split_30d6dc8961c547bdb8666410203ec212_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3;
            Unity_Add_float3(_Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean, _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3;
            Unity_Add_float3(_Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            Unity_Branch_float3(_Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3, _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3, _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            #else
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3;
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
            UnityTexture2D _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.tex, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.samplerstate, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.GetTransformedUV((_UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4.xy)) );
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_R_4_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.r;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_G_5_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.g;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_B_6_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.b;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float, _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
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
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float;
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
        float4 _Lightmap_Right_R_Left_G_Top_B_Bottom_A_TexelSize;
        float4 _Lightmap_Front_R_Back_G_Emission_B_Transparency_A_TexelSize;
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
        TEXTURE2D(_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        SAMPLER(sampler_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        TEXTURE2D(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
        SAMPLER(sampler_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
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
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_51e86316bdbf41249868945a9b6b9a4c_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[0];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[1];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_B_3_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[2];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float;
            Unity_Multiply_float_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, 0.5, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float;
            Unity_Subtract_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float, 0, _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_R_1_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[0];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_G_2_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[1];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[2];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_999d092efd29405dbd949541922cda73_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float;
            Unity_Branch_float(_Property_999d092efd29405dbd949541922cda73_Out_0_Boolean, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3 = float3(_Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3;
            _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3 = TransformObjectToWorld(_Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3, (_Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float.xxx), _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3, _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3, _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3, (_Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float.xxx), _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[0];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_G_2_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[1];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[2];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4;
            float3 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3;
            float2 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2;
            Unity_Combine_float(_Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float, _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float, 0, 0, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.tex, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.samplerstate, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.GetTransformedUV(_Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_G_6_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_B_7_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_A_8_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float;
            Unity_Branch_float(_Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean, _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float, 0, _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float;
            Unity_Absolute_float(_Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float, _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float;
            Unity_Power_float(_Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float, 2, _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float;
            Unity_Multiply_float_float(_Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float, _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float, _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[0];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_G_2_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[1];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[2];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_A_4_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2 = float2(_Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float, _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_8c455b935021482ab84f271349aa08d0_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float;
            Unity_Subtract_float(_Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float;
            Unity_Clamp_float(_Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float, 0.0001, 1000, _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float;
            Unity_Divide_float(_Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float;
            Unity_Absolute_float(_Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float, _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float;
            Unity_Power_float(_Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float, _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float, _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float;
            Unity_Multiply_float_float(_Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float;
            Unity_Absolute_float(_Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float, _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float;
            Unity_Power_float(_Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float, _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float, _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float;
            Unity_SquareRoot_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float;
            Unity_Multiply_float_float(_Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float;
            Unity_Branch_float(_Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float;
            Unity_Multiply_float_float(_Property_8c455b935021482ab84f271349aa08d0_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2, (_Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float.xx), _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[0];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[1];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_B_3_Float = 0;
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3 = float3(_Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float, 0, _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float.xxx), _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3;
            Unity_Add_float3(_Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_R_1_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[0];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_G_2_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[1];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_B_3_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[2];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3, (_Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float.xxx), _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3, _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3, (_Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float.xxx), _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[0];
            float _Split_9a881e39bf104d84a60a7983a19fb133_G_2_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[1];
            float _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[2];
            float _Split_9a881e39bf104d84a60a7983a19fb133_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4;
            float3 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3;
            float2 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2;
            Unity_Combine_float(_Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float, _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float, 0, 0, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.tex, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.samplerstate, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.GetTransformedUV(_Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_A_8_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4;
            float3 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3;
            float2 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float, 0, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3;
            Unity_Add_float3(_Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3, (_Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float.xxx), _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3, (_Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float.xxx), _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_30d6dc8961c547bdb8666410203ec212_R_1_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[0];
            float _Split_30d6dc8961c547bdb8666410203ec212_G_2_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[1];
            float _Split_30d6dc8961c547bdb8666410203ec212_B_3_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[2];
            float _Split_30d6dc8961c547bdb8666410203ec212_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3;
            Unity_Add_float3(_Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean, _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3;
            Unity_Add_float3(_Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            Unity_Branch_float3(_Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3, _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3, _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            #else
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3;
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
            UnityTexture2D _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.tex, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.samplerstate, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.GetTransformedUV((_UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4.xy)) );
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_R_4_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.r;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_G_5_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.g;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_B_6_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.b;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float, _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
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
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float;
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
        float4 _Lightmap_Right_R_Left_G_Top_B_Bottom_A_TexelSize;
        float4 _Lightmap_Front_R_Back_G_Emission_B_Transparency_A_TexelSize;
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
        TEXTURE2D(_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        SAMPLER(sampler_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        TEXTURE2D(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
        SAMPLER(sampler_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
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
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_51e86316bdbf41249868945a9b6b9a4c_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[0];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[1];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_B_3_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[2];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float;
            Unity_Multiply_float_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, 0.5, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float;
            Unity_Subtract_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float, 0, _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_R_1_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[0];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_G_2_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[1];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[2];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_999d092efd29405dbd949541922cda73_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float;
            Unity_Branch_float(_Property_999d092efd29405dbd949541922cda73_Out_0_Boolean, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3 = float3(_Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3;
            _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3 = TransformObjectToWorld(_Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3, (_Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float.xxx), _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3, _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3, _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3, (_Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float.xxx), _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[0];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_G_2_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[1];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[2];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4;
            float3 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3;
            float2 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2;
            Unity_Combine_float(_Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float, _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float, 0, 0, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.tex, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.samplerstate, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.GetTransformedUV(_Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_G_6_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_B_7_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_A_8_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float;
            Unity_Branch_float(_Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean, _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float, 0, _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float;
            Unity_Absolute_float(_Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float, _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float;
            Unity_Power_float(_Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float, 2, _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float;
            Unity_Multiply_float_float(_Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float, _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float, _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[0];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_G_2_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[1];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[2];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_A_4_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2 = float2(_Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float, _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_8c455b935021482ab84f271349aa08d0_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float;
            Unity_Subtract_float(_Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float;
            Unity_Clamp_float(_Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float, 0.0001, 1000, _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float;
            Unity_Divide_float(_Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float;
            Unity_Absolute_float(_Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float, _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float;
            Unity_Power_float(_Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float, _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float, _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float;
            Unity_Multiply_float_float(_Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float;
            Unity_Absolute_float(_Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float, _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float;
            Unity_Power_float(_Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float, _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float, _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float;
            Unity_SquareRoot_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float;
            Unity_Multiply_float_float(_Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float;
            Unity_Branch_float(_Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float;
            Unity_Multiply_float_float(_Property_8c455b935021482ab84f271349aa08d0_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2, (_Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float.xx), _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[0];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[1];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_B_3_Float = 0;
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3 = float3(_Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float, 0, _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float.xxx), _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3;
            Unity_Add_float3(_Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_R_1_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[0];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_G_2_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[1];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_B_3_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[2];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3, (_Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float.xxx), _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3, _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3, (_Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float.xxx), _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[0];
            float _Split_9a881e39bf104d84a60a7983a19fb133_G_2_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[1];
            float _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[2];
            float _Split_9a881e39bf104d84a60a7983a19fb133_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4;
            float3 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3;
            float2 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2;
            Unity_Combine_float(_Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float, _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float, 0, 0, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.tex, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.samplerstate, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.GetTransformedUV(_Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_A_8_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4;
            float3 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3;
            float2 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float, 0, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3;
            Unity_Add_float3(_Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3, (_Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float.xxx), _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3, (_Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float.xxx), _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_30d6dc8961c547bdb8666410203ec212_R_1_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[0];
            float _Split_30d6dc8961c547bdb8666410203ec212_G_2_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[1];
            float _Split_30d6dc8961c547bdb8666410203ec212_B_3_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[2];
            float _Split_30d6dc8961c547bdb8666410203ec212_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3;
            Unity_Add_float3(_Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean, _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3;
            Unity_Add_float3(_Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            Unity_Branch_float3(_Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3, _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3, _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            #else
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3;
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
            UnityTexture2D _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.tex, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.samplerstate, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.GetTransformedUV((_UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4.xy)) );
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_R_4_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.r;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_G_5_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.g;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_B_6_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.b;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float, _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
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
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float;
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
        float4 _Lightmap_Right_R_Left_G_Top_B_Bottom_A_TexelSize;
        float4 _Lightmap_Front_R_Back_G_Emission_B_Transparency_A_TexelSize;
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
        TEXTURE2D(_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        SAMPLER(sampler_Lightmap_Right_R_Left_G_Top_B_Bottom_A);
        TEXTURE2D(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
        SAMPLER(sampler_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
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
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_51e86316bdbf41249868945a9b6b9a4c_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_51e86316bdbf41249868945a9b6b9a4c_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[0];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[1];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_B_3_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[2];
            float _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float = _UV_d260ee300109428a831bcc246fb74d7f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float;
            Unity_Multiply_float_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, 0.5, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float;
            Unity_Subtract_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Multiply_84a7eb0625f74ded97fa82b438888ead_Out_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_51e86316bdbf41249868945a9b6b9a4c_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_6485a5e5fc00420aa71bb4853d7b6a0c_Out_0_Float, 0, _Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_R_1_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[0];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_G_2_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[1];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[2];
            float _Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float = _UV_804e4cb75d0148baa2f9eb8562d4fbf2_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_999d092efd29405dbd949541922cda73_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float;
            Unity_Branch_float(_Property_999d092efd29405dbd949541922cda73_Out_0_Boolean, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_R_1_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3 = float3(_Split_4b5355d86f294775bcc4d8a614fa2ad7_A_4_Float, _Branch_3baefd489b214ce0a3e5894cc4059313_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3;
            _Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3 = TransformObjectToWorld(_Vector3_bd92b40bc7d74b0da892a905c39b9876_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_e2c4dc34348f45c89df3c099d497b9b3_Out_0_Vector3, (_Property_5ceebd5609ba45bfb7d60533d2aa9ee0_Out_0_Float.xxx), _Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_882e46ecd6e34e8bb8248eb13b3673f5_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_cb8288514de1463e882f3f64bcfd6bb3_Out_1_Vector3, _Multiply_7f4df34f138245bd8c11328a71167118_Out_2_Vector3, _Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_b958c803f890438b831f8ebebd2b263d_Out_2_Vector3, (_Property_e0e124811527439f82b4c08c826d5f40_Out_0_Float.xxx), _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[0];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_G_2_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[1];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float = _Multiply_13a4fcd13660486aa724a0bdffc88c7f_Out_2_Vector3[2];
            float _Split_c26c74e389b84b5c9b8fd8a86f468596_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4;
            float3 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3;
            float2 _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2;
            Unity_Combine_float(_Split_c26c74e389b84b5c9b8fd8a86f468596_R_1_Float, _Split_c26c74e389b84b5c9b8fd8a86f468596_B_3_Float, 0, 0, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGBA_4_Vector4, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RGB_5_Vector3, _Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.tex, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.samplerstate, _Property_7e6d429c4da441c1b498e8fbb8959725_Out_0_Texture2D.GetTransformedUV(_Combine_35ab9d94273b43e3bb3d450999a28dc6_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_G_6_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_B_7_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_A_8_Float = _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float;
            Unity_Branch_float(_Comparison_c770ad6cdb554abcbb013a79867631cb_Out_2_Boolean, _SampleTexture2DLOD_bbd6d3451ace496e84771ae90d404b88_R_5_Float, 0, _Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float;
            Unity_Absolute_float(_Branch_defee3ec08f741aa951b674fd2e01b0d_Out_3_Float, _Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float;
            Unity_Power_float(_Absolute_c39aaa2d7ff84db6b9be8e56ffb3805c_Out_1_Float, 2, _Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float;
            Unity_Multiply_float_float(_Power_e613846ef5f94204b6179e80f6b9019f_Out_2_Float, _Property_bc217c941c424424b253d71ebfaf737f_Out_0_Float, _Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[0];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_G_2_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[1];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[2];
            float _Split_e4fa51084eaf44ea82a412fa0eba6a53_A_4_Float = _Property_935f78049a6f4efcbf2d315d7a0caf2c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2 = float2(_Split_e4fa51084eaf44ea82a412fa0eba6a53_R_1_Float, _Split_e4fa51084eaf44ea82a412fa0eba6a53_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_8c455b935021482ab84f271349aa08d0_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_fd7bec5e98274b1998d8c2a8f0219a65_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float;
            Unity_Subtract_float(_Split_fd7bec5e98274b1998d8c2a8f0219a65_G_2_Float, _Subtract_ae9a739a4b1640128d23a1c98b0ed485_Out_2_Float, _Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float;
            Unity_Clamp_float(_Subtract_48727684c1654f50b3b7396eb5288c9f_Out_2_Float, 0.0001, 1000, _Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float;
            Unity_Divide_float(_Clamp_2a5dc41d04024c0ebf3398fe75b2ec46_Out_3_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float;
            Unity_Absolute_float(_Divide_4c9d5b53c9e646638b978c26f61d16be_Out_2_Float, _Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float;
            Unity_Power_float(_Absolute_41152ecc74ff4504a418ff58e474c0fa_Out_1_Float, _Property_636cdb88db504667b3c2f4329e46976d_Out_0_Float, _Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float;
            Unity_Multiply_float_float(_Power_c7336604aafb4e3e81a9d041f27d8959_Out_2_Float, _Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float;
            Unity_Absolute_float(_Split_4b5355d86f294775bcc4d8a614fa2ad7_B_3_Float, _Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float;
            Unity_Power_float(_Absolute_9572e73249e046fb86cfbc5bbbedac28_Out_1_Float, _Property_4532d4aa354d4b0ca92a42b8ed9db656_Out_0_Float, _Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float;
            Unity_SquareRoot_float(_Split_a9e9587ad85c41f0b5a5203090eb424b_A_4_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float;
            Unity_Multiply_float_float(_Power_08511388f74542c587ca03afdc2c51ee_Out_2_Float, _SquareRoot_70d730a13d1a4399bacf15f04d6ac0a7_Out_1_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float;
            Unity_Branch_float(_Property_7630bd3b8b734f1f980158f230fcbcb1_Out_0_Boolean, _Multiply_f5f6c54245a54b9abfcc0e25e93b6be0_Out_2_Float, _Multiply_5c40aaea42a04151933be72c363721da_Out_2_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float;
            Unity_Multiply_float_float(_Property_8c455b935021482ab84f271349aa08d0_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_3b2eeed691bb4915b71a621907c266bb_Out_0_Vector2, (_Multiply_564505a8796c42a680c300795676e1bd_Out_2_Float.xx), _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[0];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float = _Multiply_731dea6d9667403b867eaefdccc1b2fb_Out_2_Vector2[1];
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_B_3_Float = 0;
            float _Split_5fe646537fd34d8f8f6ed421c6dd282e_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3 = float3(_Split_5fe646537fd34d8f8f6ed421c6dd282e_R_1_Float, 0, _Split_5fe646537fd34d8f8f6ed421c6dd282e_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_ba9dbd903cf249498c9fff6d67e45425_Out_2_Float.xxx), _Vector3_52151e3e314442e9a5bdbd457556f353_Out_0_Vector3, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3;
            Unity_Add_float3(_Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_R_1_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[0];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_G_2_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[1];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_B_3_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[2];
            float _Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float = _Property_b02f4d86f3924bc9a333dd0e7c52ff8c_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_3b9f0772ac08455da2a81a3940f13b95_Out_0_Vector3, (_Split_e2fcb7b0723b417598d6b3ea78dc48c3_A_4_Float.xxx), _Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_435d37d14d0547afbb9f7289188ba636_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_8087277456eb47eb8cdfa7a9eaf38cc6_Out_2_Vector3, _Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_8757738a246d488ebca2301ab758dd6b_Out_2_Vector3, (_Property_c299ef49892942fc83f209ab880ddfbe_Out_0_Float.xxx), _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[0];
            float _Split_9a881e39bf104d84a60a7983a19fb133_G_2_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[1];
            float _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float = _Multiply_3f42631e4f204bfa8ed8b7b57d4ee048_Out_2_Vector3[2];
            float _Split_9a881e39bf104d84a60a7983a19fb133_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4;
            float3 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3;
            float2 _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2;
            Unity_Combine_float(_Split_9a881e39bf104d84a60a7983a19fb133_R_1_Float, _Split_9a881e39bf104d84a60a7983a19fb133_B_3_Float, 0, 0, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGBA_4_Vector4, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RGB_5_Vector3, _Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.tex, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.samplerstate, _Property_55fa750a5f4640e19f0cdf3cebbd4d50_Out_0_Texture2D.GetTransformedUV(_Combine_e7a30a0acb4c4da78f08d998df76c3e7_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_A_8_Float = _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4;
            float3 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3;
            float2 _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_R_5_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_G_6_Float, _SampleTexture2DLOD_bda6728c233943bf9433e93832bc24da_B_7_Float, 0, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGBA_4_Vector4, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, _Combine_374c9e5e592c42ffa176b2bdf77e4f37_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3;
            Unity_Add_float3(_Combine_374c9e5e592c42ffa176b2bdf77e4f37_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_a16f4dd7e9df45a8aac93832264c7f2e_Out_2_Vector3, (_Property_72e5fd0568dc414b8889e600355d2800_Out_0_Float.xxx), _Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d8f62fa2f3964852951c75ec987bd173_Out_0_Float, _Branch_05b70f752e2e423f8184ca827773a833_Out_3_Float, _Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_3e25417a7b0147eb99ef7c5bd168b2d1_Out_2_Vector3, (_Multiply_eb65821fc9c64ac8b4fa592ca1d23ad5_Out_2_Float.xxx), _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_30d6dc8961c547bdb8666410203ec212_R_1_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[0];
            float _Split_30d6dc8961c547bdb8666410203ec212_G_2_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[1];
            float _Split_30d6dc8961c547bdb8666410203ec212_B_3_Float = _Multiply_e09163584f634506972b87502540491f_Out_2_Vector3[2];
            float _Split_30d6dc8961c547bdb8666410203ec212_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3;
            Unity_Add_float3(_Add_eca3c9a29f8b4fcda5184ec9a8bbf801_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_0e40724394634515b36c0905780a845b_Out_2_Boolean, _Add_b017f7f8a6b34bbe811d7c282b0082a9_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_3f8fc5c6680b45cd95c3435667a68a7c_Out_2_Vector3, _Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3;
            Unity_Add_float3(_Add_b41c68d3c7fa48a9bcd092f8044a12b9_Out_2_Vector3, (_Split_30d6dc8961c547bdb8666410203ec212_G_2_Float.xxx), _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float3 _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            Unity_Branch_float3(_Property_9ae46c0e10a846479e1e2fc99ff94e0c_Out_0_Boolean, _Branch_0df880a5ac124080a09e89ab691aa5fb_Out_3_Vector3, _Add_d995271898734401b88f81ff150e98ad_Out_2_Vector3, _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_WIND_ON)
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = _Branch_f2b4b49d835d44dcb5767283ca678600_Out_3_Vector3;
            #else
            float3 _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_807299a519014985be9b7994c0bcfa87_Out_0_Vector3;
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
            UnityTexture2D _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Lightmap_Front_R_Back_G_Emission_B_Transparency_A);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.tex, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.samplerstate, _Property_0c39d1ab422945ba881ee6129c95ba1e_Out_0_Texture2D.GetTransformedUV((_UV_33762d284a2446109fbc9f679c04d7c2_Out_0_Vector4.xy)) );
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_R_4_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.r;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_G_5_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.g;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_B_6_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.b;
            float _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float = _SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_12920bdaccef158ab9bd191cc9e45c04_R_1_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[0];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_G_2_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[1];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_B_3_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[2];
            float _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float = _Clamp_6b244204ef834a29b6c6c6c2edf26fe6_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_693c72d059a841c5b990c09e5ce21e42_A_7_Float, _Split_12920bdaccef158ab9bd191cc9e45c04_A_4_Float, _Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_04951b1c5969598aa7f847c67f0bab47_Out_2_Float, _Property_4ec3b5ce0aae410db631c9f2d2d71fac_Out_0_Float, _Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_bfce62f247c647b48fbe67e3215eec83_Out_2_Float, IN.Alpha_Dist, _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float);
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
            float _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_b90a4614d9dc4b668996036c0e29534b_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float = _Multiply_6b1753f0fae453839d7f1aff859ce954_Out_2_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e23b1daac78b0a87a81cf357c01bb1c6_Out_0_Float = _AlphaClipThreshold;
            #endif
            surface.Alpha = _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Float;
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