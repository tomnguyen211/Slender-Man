Shader "NatureManufacture/URP/Particles/Fire Unlit"
{
    Properties
    {
        [NoScaleOffset]_Emission_Flipbook("Emission Flipbook (RGB)", 2D) = "white" {}
        [ToggleUI]_Use_Texture_as_Alpha("Use Texture as Alpha", Float) = 0
        _Alpha_Multiplier("Alpha Multiplier", Float) = 1
        _Emission_Intensity("Emission Intensity", Float) = 1
        [HDR]_Emission_Color("Emission Color", Color) = (32, 32, 32, 0)
        [ToggleUI]_Wind_from_Center_T_Age_F("Wind from Center (T) Age (F)", Float) = 0
        _Gust_Strength("Gust Strength", Float) = 0
        _Shiver_Strength("Shiver Strength", Float) = 0
        _Bend_Strength("Bend Strength", Range(0.1, 4)) = 2
        _Intersection_Offset("Intersection Offset", Float) = 0.5
        [Toggle]USE_TRANSPARENCY_INTERSECTION("Use Transparency Intersection", Float) = 0
        [Toggle]USE_WIND("Use Wind", Float) = 0
        [HideInInspector]_CastShadows("_CastShadows", Float) = 0
        [HideInInspector]_Surface("_Surface", Float) = 1
        [HideInInspector]_Blend("_Blend", Float) = 2
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
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 color : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS : INTERP3;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
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
            output.positionWS = input.positionWS.xyz;
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
        float4 _Emission_Flipbook_TexelSize;
        float _Use_Texture_as_Alpha;
        float _Alpha_Multiplier;
        float _Emission_Intensity;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        float _Intersection_Offset;
        float4 _Emission_Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Emission_Flipbook);
        SAMPLER(sampler_Emission_Flipbook);
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
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
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
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_053b93d341c54017acdcf5ca085ba201_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_053b93d341c54017acdcf5ca085ba201_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_053b93d341c54017acdcf5ca085ba201_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_053b93d341c54017acdcf5ca085ba201_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_910afe74b35d4bea90313d0d57c29fb5_R_1_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[0];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_G_2_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[1];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[2];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[0];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_G_2_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[1];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[2];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float;
            Unity_Multiply_float_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, 0.5, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float;
            Unity_Subtract_float(_Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_053b93d341c54017acdcf5ca085ba201_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float, 0, _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float;
            Unity_Branch_float(_Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3 = float3(_Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3;
            _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3 = TransformObjectToWorld(_Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3, (_Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float.xxx), _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3, _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3, _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_92de9af0229e4016afc0dad754327a92_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3, (_Property_92de9af0229e4016afc0dad754327a92_Out_0_Float.xxx), _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[0];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_G_2_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[1];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[2];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4;
            float3 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3;
            float2 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2;
            Unity_Combine_float(_Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float, _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float, 0, 0, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.tex, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.samplerstate, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.GetTransformedUV(_Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_G_6_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_B_7_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_A_8_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float;
            Unity_Branch_float(_Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean, _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float, 0, _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float;
            Unity_Absolute_float(_Branch_924e9783007548e1adfe644e2a385413_Out_3_Float, _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float;
            Unity_Power_float(_Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float, 2, _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float;
            Unity_Multiply_float_float(_Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float, _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float, _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[0];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_G_2_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[1];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[2];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_A_4_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2 = float2(_Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float, _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_7f979362cf5546918a12aded783bbac5_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float;
            Unity_Subtract_float(_Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float;
            Unity_Clamp_float(_Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float, 0.0001, 1000, _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float;
            Unity_Divide_float(_Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float;
            Unity_Absolute_float(_Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float, _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float;
            Unity_Power_float(_Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float, _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float, _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float;
            Unity_Multiply_float_float(_Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float;
            Unity_Absolute_float(_Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float, _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float;
            Unity_Power_float(_Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float, _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float, _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float;
            Unity_SquareRoot_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float;
            Unity_Multiply_float_float(_Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float;
            Unity_Branch_float(_Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float;
            Unity_Multiply_float_float(_Property_7f979362cf5546918a12aded783bbac5_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2, (_Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float.xx), _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e550a9498ca049469521454832ad1fbf_R_1_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[0];
            float _Split_e550a9498ca049469521454832ad1fbf_G_2_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[1];
            float _Split_e550a9498ca049469521454832ad1fbf_B_3_Float = 0;
            float _Split_e550a9498ca049469521454832ad1fbf_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3 = float3(_Split_e550a9498ca049469521454832ad1fbf_R_1_Float, 0, _Split_e550a9498ca049469521454832ad1fbf_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float.xxx), _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3;
            Unity_Add_float3(_Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_R_1_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[0];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_G_2_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[1];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_B_3_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[2];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3, (_Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float.xxx), _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3, _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3, (_Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float.xxx), _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[0];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_G_2_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[1];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[2];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4;
            float3 _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3;
            float2 _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2;
            Unity_Combine_float(_Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float, _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float, 0, 0, _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4, _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3, _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.tex, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.samplerstate, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.GetTransformedUV(_Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_A_8_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4;
            float3 _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3;
            float2 _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float, 0, _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4, _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3;
            Unity_Add_float3(_Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_70940dc414e9445798faf654716fdba6_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3, (_Property_70940dc414e9445798faf654716fdba6_Out_0_Float.xxx), _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float;
            Unity_Multiply_float_float(_Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3, (_Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float.xxx), _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_R_1_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[0];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[1];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_B_3_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[2];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3;
            Unity_Add_float3(_Add_cd114e704768447cb940749c137d5804_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean, _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3;
            Unity_Add_float3(_Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            Unity_Branch_float3(_Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3, _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3, _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            #else
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Clamp_dcbf389ae27742c68f4cca26f8129ef9_Out_3_Vector4;
            Unity_Clamp_float4(IN.VertexColor, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_dcbf389ae27742c68f4cca26f8129ef9_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_4902bdfbd9694d588c1093021f69bd27_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Emission_Color) : _Emission_Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emission_Flipbook);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.tex, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.samplerstate, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.GetTransformedUV((_UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4.xy)) );
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.r;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.g;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.b;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_A_7_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Multiply_985510ff28c84af0b7fda8323b657b5b_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4902bdfbd9694d588c1093021f69bd27_Out_0_Vector4, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4, _Multiply_985510ff28c84af0b7fda8323b657b5b_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_cc81c96d78ef46c09433e5ebccfd6e56_Out_0_Float = _Emission_Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Multiply_5d4a7abb541b42019d6e193099bc56ce_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_985510ff28c84af0b7fda8323b657b5b_Out_2_Vector4, (_Property_cc81c96d78ef46c09433e5ebccfd6e56_Out_0_Float.xxxx), _Multiply_5d4a7abb541b42019d6e193099bc56ce_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Multiply_eeab5989cd9349d5a4dedd4c5632a8cd_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float.xxxx), _Multiply_5d4a7abb541b42019d6e193099bc56ce_Out_2_Vector4, _Multiply_eeab5989cd9349d5a4dedd4c5632a8cd_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float4 _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Vector4 = _Multiply_eeab5989cd9349d5a4dedd4c5632a8cd_Out_2_Vector4;
            #else
            float4 _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Vector4 = _Multiply_5d4a7abb541b42019d6e193099bc56ce_Out_2_Vector4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Multiply_5454d995e84044dba566d13eb2fd74c1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Clamp_dcbf389ae27742c68f4cca26f8129ef9_Out_3_Vector4, _UseTransparencyIntersection_6e1bd62378ca48c69574eedd569b19cb_Out_0_Vector4, _Multiply_5454d995e84044dba566d13eb2fd74c1_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean = _Use_Texture_as_Alpha;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float, _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float;
            Unity_Add_float(_Add_21f4fac385494c629ba6655c03978c51_Out_2_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float, _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float;
            Unity_Multiply_float_float(_Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float, 0.33, _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float, _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float, _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            Unity_Saturate_float(_Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float, _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            Unity_Branch_float(_Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean, _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float, 1, _Branch_6088271999854d34a90750407a8401a3_Out_3_Float);
            #endif
            surface.BaseColor = (_Multiply_5454d995e84044dba566d13eb2fd74c1_Out_2_Vector4.xyz);
            surface.Alpha = _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            surface.AlphaClipThreshold = 0.5;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
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
            output.positionWS = input.positionWS.xyz;
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
        float4 _Emission_Flipbook_TexelSize;
        float _Use_Texture_as_Alpha;
        float _Alpha_Multiplier;
        float _Emission_Intensity;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        float _Intersection_Offset;
        float4 _Emission_Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Emission_Flipbook);
        SAMPLER(sampler_Emission_Flipbook);
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
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_053b93d341c54017acdcf5ca085ba201_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_053b93d341c54017acdcf5ca085ba201_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_053b93d341c54017acdcf5ca085ba201_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_053b93d341c54017acdcf5ca085ba201_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_910afe74b35d4bea90313d0d57c29fb5_R_1_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[0];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_G_2_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[1];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[2];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[0];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_G_2_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[1];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[2];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float;
            Unity_Multiply_float_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, 0.5, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float;
            Unity_Subtract_float(_Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_053b93d341c54017acdcf5ca085ba201_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float, 0, _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float;
            Unity_Branch_float(_Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3 = float3(_Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3;
            _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3 = TransformObjectToWorld(_Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3, (_Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float.xxx), _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3, _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3, _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_92de9af0229e4016afc0dad754327a92_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3, (_Property_92de9af0229e4016afc0dad754327a92_Out_0_Float.xxx), _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[0];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_G_2_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[1];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[2];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4;
            float3 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3;
            float2 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2;
            Unity_Combine_float(_Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float, _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float, 0, 0, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.tex, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.samplerstate, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.GetTransformedUV(_Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_G_6_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_B_7_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_A_8_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float;
            Unity_Branch_float(_Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean, _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float, 0, _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float;
            Unity_Absolute_float(_Branch_924e9783007548e1adfe644e2a385413_Out_3_Float, _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float;
            Unity_Power_float(_Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float, 2, _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float;
            Unity_Multiply_float_float(_Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float, _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float, _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[0];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_G_2_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[1];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[2];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_A_4_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2 = float2(_Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float, _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_7f979362cf5546918a12aded783bbac5_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float;
            Unity_Subtract_float(_Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float;
            Unity_Clamp_float(_Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float, 0.0001, 1000, _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float;
            Unity_Divide_float(_Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float;
            Unity_Absolute_float(_Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float, _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float;
            Unity_Power_float(_Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float, _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float, _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float;
            Unity_Multiply_float_float(_Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float;
            Unity_Absolute_float(_Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float, _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float;
            Unity_Power_float(_Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float, _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float, _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float;
            Unity_SquareRoot_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float;
            Unity_Multiply_float_float(_Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float;
            Unity_Branch_float(_Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float;
            Unity_Multiply_float_float(_Property_7f979362cf5546918a12aded783bbac5_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2, (_Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float.xx), _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e550a9498ca049469521454832ad1fbf_R_1_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[0];
            float _Split_e550a9498ca049469521454832ad1fbf_G_2_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[1];
            float _Split_e550a9498ca049469521454832ad1fbf_B_3_Float = 0;
            float _Split_e550a9498ca049469521454832ad1fbf_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3 = float3(_Split_e550a9498ca049469521454832ad1fbf_R_1_Float, 0, _Split_e550a9498ca049469521454832ad1fbf_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float.xxx), _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3;
            Unity_Add_float3(_Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_R_1_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[0];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_G_2_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[1];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_B_3_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[2];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3, (_Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float.xxx), _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3, _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3, (_Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float.xxx), _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[0];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_G_2_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[1];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[2];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4;
            float3 _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3;
            float2 _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2;
            Unity_Combine_float(_Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float, _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float, 0, 0, _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4, _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3, _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.tex, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.samplerstate, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.GetTransformedUV(_Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_A_8_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4;
            float3 _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3;
            float2 _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float, 0, _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4, _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3;
            Unity_Add_float3(_Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_70940dc414e9445798faf654716fdba6_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3, (_Property_70940dc414e9445798faf654716fdba6_Out_0_Float.xxx), _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float;
            Unity_Multiply_float_float(_Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3, (_Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float.xxx), _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_R_1_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[0];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[1];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_B_3_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[2];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3;
            Unity_Add_float3(_Add_cd114e704768447cb940749c137d5804_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean, _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3;
            Unity_Add_float3(_Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            Unity_Branch_float3(_Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3, _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3, _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            #else
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean = _Use_Texture_as_Alpha;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emission_Flipbook);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.tex, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.samplerstate, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.GetTransformedUV((_UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4.xy)) );
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.r;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.g;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.b;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_A_7_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float, _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float;
            Unity_Add_float(_Add_21f4fac385494c629ba6655c03978c51_Out_2_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float, _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float;
            Unity_Multiply_float_float(_Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float, 0.33, _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float, _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float, _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            Unity_Saturate_float(_Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float, _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            Unity_Branch_float(_Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean, _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float, 1, _Branch_6088271999854d34a90750407a8401a3_Out_3_Float);
            #endif
            surface.Alpha = _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            surface.AlphaClipThreshold = 0.5;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
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
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
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
            output.positionWS = input.positionWS.xyz;
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
        float4 _Emission_Flipbook_TexelSize;
        float _Use_Texture_as_Alpha;
        float _Alpha_Multiplier;
        float _Emission_Intensity;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        float _Intersection_Offset;
        float4 _Emission_Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Emission_Flipbook);
        SAMPLER(sampler_Emission_Flipbook);
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
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_053b93d341c54017acdcf5ca085ba201_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_053b93d341c54017acdcf5ca085ba201_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_053b93d341c54017acdcf5ca085ba201_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_053b93d341c54017acdcf5ca085ba201_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_910afe74b35d4bea90313d0d57c29fb5_R_1_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[0];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_G_2_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[1];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[2];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[0];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_G_2_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[1];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[2];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float;
            Unity_Multiply_float_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, 0.5, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float;
            Unity_Subtract_float(_Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_053b93d341c54017acdcf5ca085ba201_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float, 0, _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float;
            Unity_Branch_float(_Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3 = float3(_Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3;
            _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3 = TransformObjectToWorld(_Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3, (_Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float.xxx), _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3, _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3, _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_92de9af0229e4016afc0dad754327a92_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3, (_Property_92de9af0229e4016afc0dad754327a92_Out_0_Float.xxx), _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[0];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_G_2_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[1];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[2];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4;
            float3 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3;
            float2 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2;
            Unity_Combine_float(_Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float, _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float, 0, 0, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.tex, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.samplerstate, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.GetTransformedUV(_Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_G_6_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_B_7_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_A_8_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float;
            Unity_Branch_float(_Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean, _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float, 0, _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float;
            Unity_Absolute_float(_Branch_924e9783007548e1adfe644e2a385413_Out_3_Float, _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float;
            Unity_Power_float(_Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float, 2, _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float;
            Unity_Multiply_float_float(_Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float, _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float, _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[0];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_G_2_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[1];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[2];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_A_4_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2 = float2(_Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float, _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_7f979362cf5546918a12aded783bbac5_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float;
            Unity_Subtract_float(_Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float;
            Unity_Clamp_float(_Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float, 0.0001, 1000, _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float;
            Unity_Divide_float(_Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float;
            Unity_Absolute_float(_Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float, _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float;
            Unity_Power_float(_Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float, _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float, _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float;
            Unity_Multiply_float_float(_Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float;
            Unity_Absolute_float(_Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float, _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float;
            Unity_Power_float(_Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float, _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float, _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float;
            Unity_SquareRoot_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float;
            Unity_Multiply_float_float(_Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float;
            Unity_Branch_float(_Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float;
            Unity_Multiply_float_float(_Property_7f979362cf5546918a12aded783bbac5_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2, (_Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float.xx), _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e550a9498ca049469521454832ad1fbf_R_1_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[0];
            float _Split_e550a9498ca049469521454832ad1fbf_G_2_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[1];
            float _Split_e550a9498ca049469521454832ad1fbf_B_3_Float = 0;
            float _Split_e550a9498ca049469521454832ad1fbf_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3 = float3(_Split_e550a9498ca049469521454832ad1fbf_R_1_Float, 0, _Split_e550a9498ca049469521454832ad1fbf_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float.xxx), _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3;
            Unity_Add_float3(_Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_R_1_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[0];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_G_2_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[1];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_B_3_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[2];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3, (_Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float.xxx), _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3, _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3, (_Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float.xxx), _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[0];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_G_2_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[1];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[2];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4;
            float3 _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3;
            float2 _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2;
            Unity_Combine_float(_Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float, _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float, 0, 0, _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4, _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3, _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.tex, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.samplerstate, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.GetTransformedUV(_Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_A_8_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4;
            float3 _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3;
            float2 _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float, 0, _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4, _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3;
            Unity_Add_float3(_Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_70940dc414e9445798faf654716fdba6_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3, (_Property_70940dc414e9445798faf654716fdba6_Out_0_Float.xxx), _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float;
            Unity_Multiply_float_float(_Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3, (_Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float.xxx), _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_R_1_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[0];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[1];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_B_3_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[2];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3;
            Unity_Add_float3(_Add_cd114e704768447cb940749c137d5804_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean, _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3;
            Unity_Add_float3(_Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            Unity_Branch_float3(_Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3, _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3, _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            #else
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean = _Use_Texture_as_Alpha;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emission_Flipbook);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.tex, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.samplerstate, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.GetTransformedUV((_UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4.xy)) );
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.r;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.g;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.b;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_A_7_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float, _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float;
            Unity_Add_float(_Add_21f4fac385494c629ba6655c03978c51_Out_2_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float, _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float;
            Unity_Multiply_float_float(_Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float, 0.33, _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float, _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float, _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            Unity_Saturate_float(_Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float, _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            Unity_Branch_float(_Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean, _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float, 1, _Branch_6088271999854d34a90750407a8401a3_Out_3_Float);
            #endif
            surface.Alpha = _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            surface.AlphaClipThreshold = 0.5;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
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
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
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
            output.positionWS = input.positionWS.xyz;
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
        float4 _Emission_Flipbook_TexelSize;
        float _Use_Texture_as_Alpha;
        float _Alpha_Multiplier;
        float _Emission_Intensity;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        float _Intersection_Offset;
        float4 _Emission_Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Emission_Flipbook);
        SAMPLER(sampler_Emission_Flipbook);
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
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_053b93d341c54017acdcf5ca085ba201_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_053b93d341c54017acdcf5ca085ba201_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_053b93d341c54017acdcf5ca085ba201_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_053b93d341c54017acdcf5ca085ba201_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_910afe74b35d4bea90313d0d57c29fb5_R_1_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[0];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_G_2_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[1];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[2];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[0];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_G_2_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[1];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[2];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float;
            Unity_Multiply_float_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, 0.5, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float;
            Unity_Subtract_float(_Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_053b93d341c54017acdcf5ca085ba201_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float, 0, _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float;
            Unity_Branch_float(_Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3 = float3(_Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3;
            _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3 = TransformObjectToWorld(_Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3, (_Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float.xxx), _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3, _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3, _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_92de9af0229e4016afc0dad754327a92_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3, (_Property_92de9af0229e4016afc0dad754327a92_Out_0_Float.xxx), _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[0];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_G_2_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[1];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[2];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4;
            float3 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3;
            float2 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2;
            Unity_Combine_float(_Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float, _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float, 0, 0, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.tex, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.samplerstate, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.GetTransformedUV(_Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_G_6_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_B_7_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_A_8_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float;
            Unity_Branch_float(_Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean, _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float, 0, _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float;
            Unity_Absolute_float(_Branch_924e9783007548e1adfe644e2a385413_Out_3_Float, _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float;
            Unity_Power_float(_Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float, 2, _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float;
            Unity_Multiply_float_float(_Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float, _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float, _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[0];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_G_2_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[1];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[2];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_A_4_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2 = float2(_Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float, _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_7f979362cf5546918a12aded783bbac5_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float;
            Unity_Subtract_float(_Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float;
            Unity_Clamp_float(_Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float, 0.0001, 1000, _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float;
            Unity_Divide_float(_Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float;
            Unity_Absolute_float(_Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float, _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float;
            Unity_Power_float(_Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float, _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float, _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float;
            Unity_Multiply_float_float(_Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float;
            Unity_Absolute_float(_Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float, _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float;
            Unity_Power_float(_Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float, _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float, _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float;
            Unity_SquareRoot_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float;
            Unity_Multiply_float_float(_Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float;
            Unity_Branch_float(_Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float;
            Unity_Multiply_float_float(_Property_7f979362cf5546918a12aded783bbac5_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2, (_Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float.xx), _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e550a9498ca049469521454832ad1fbf_R_1_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[0];
            float _Split_e550a9498ca049469521454832ad1fbf_G_2_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[1];
            float _Split_e550a9498ca049469521454832ad1fbf_B_3_Float = 0;
            float _Split_e550a9498ca049469521454832ad1fbf_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3 = float3(_Split_e550a9498ca049469521454832ad1fbf_R_1_Float, 0, _Split_e550a9498ca049469521454832ad1fbf_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float.xxx), _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3;
            Unity_Add_float3(_Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_R_1_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[0];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_G_2_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[1];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_B_3_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[2];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3, (_Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float.xxx), _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3, _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3, (_Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float.xxx), _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[0];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_G_2_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[1];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[2];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4;
            float3 _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3;
            float2 _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2;
            Unity_Combine_float(_Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float, _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float, 0, 0, _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4, _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3, _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.tex, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.samplerstate, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.GetTransformedUV(_Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_A_8_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4;
            float3 _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3;
            float2 _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float, 0, _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4, _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3;
            Unity_Add_float3(_Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_70940dc414e9445798faf654716fdba6_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3, (_Property_70940dc414e9445798faf654716fdba6_Out_0_Float.xxx), _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float;
            Unity_Multiply_float_float(_Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3, (_Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float.xxx), _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_R_1_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[0];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[1];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_B_3_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[2];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3;
            Unity_Add_float3(_Add_cd114e704768447cb940749c137d5804_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean, _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3;
            Unity_Add_float3(_Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            Unity_Branch_float3(_Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3, _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3, _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            #else
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean = _Use_Texture_as_Alpha;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emission_Flipbook);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.tex, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.samplerstate, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.GetTransformedUV((_UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4.xy)) );
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.r;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.g;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.b;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_A_7_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float, _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float;
            Unity_Add_float(_Add_21f4fac385494c629ba6655c03978c51_Out_2_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float, _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float;
            Unity_Multiply_float_float(_Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float, 0.33, _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float, _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float, _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            Unity_Saturate_float(_Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float, _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            Unity_Branch_float(_Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean, _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float, 1, _Branch_6088271999854d34a90750407a8401a3_Out_3_Float);
            #endif
            surface.Alpha = _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            surface.AlphaClipThreshold = 0.5;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
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
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
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
            output.positionWS = input.positionWS.xyz;
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
        float4 _Emission_Flipbook_TexelSize;
        float _Use_Texture_as_Alpha;
        float _Alpha_Multiplier;
        float _Emission_Intensity;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        float _Intersection_Offset;
        float4 _Emission_Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Emission_Flipbook);
        SAMPLER(sampler_Emission_Flipbook);
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
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_053b93d341c54017acdcf5ca085ba201_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_053b93d341c54017acdcf5ca085ba201_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_053b93d341c54017acdcf5ca085ba201_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_053b93d341c54017acdcf5ca085ba201_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_910afe74b35d4bea90313d0d57c29fb5_R_1_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[0];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_G_2_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[1];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[2];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[0];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_G_2_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[1];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[2];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float;
            Unity_Multiply_float_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, 0.5, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float;
            Unity_Subtract_float(_Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_053b93d341c54017acdcf5ca085ba201_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float, 0, _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float;
            Unity_Branch_float(_Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3 = float3(_Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3;
            _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3 = TransformObjectToWorld(_Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3, (_Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float.xxx), _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3, _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3, _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_92de9af0229e4016afc0dad754327a92_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3, (_Property_92de9af0229e4016afc0dad754327a92_Out_0_Float.xxx), _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[0];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_G_2_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[1];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[2];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4;
            float3 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3;
            float2 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2;
            Unity_Combine_float(_Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float, _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float, 0, 0, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.tex, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.samplerstate, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.GetTransformedUV(_Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_G_6_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_B_7_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_A_8_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float;
            Unity_Branch_float(_Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean, _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float, 0, _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float;
            Unity_Absolute_float(_Branch_924e9783007548e1adfe644e2a385413_Out_3_Float, _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float;
            Unity_Power_float(_Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float, 2, _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float;
            Unity_Multiply_float_float(_Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float, _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float, _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[0];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_G_2_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[1];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[2];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_A_4_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2 = float2(_Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float, _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_7f979362cf5546918a12aded783bbac5_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float;
            Unity_Subtract_float(_Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float;
            Unity_Clamp_float(_Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float, 0.0001, 1000, _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float;
            Unity_Divide_float(_Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float;
            Unity_Absolute_float(_Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float, _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float;
            Unity_Power_float(_Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float, _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float, _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float;
            Unity_Multiply_float_float(_Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float;
            Unity_Absolute_float(_Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float, _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float;
            Unity_Power_float(_Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float, _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float, _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float;
            Unity_SquareRoot_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float;
            Unity_Multiply_float_float(_Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float;
            Unity_Branch_float(_Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float;
            Unity_Multiply_float_float(_Property_7f979362cf5546918a12aded783bbac5_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2, (_Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float.xx), _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e550a9498ca049469521454832ad1fbf_R_1_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[0];
            float _Split_e550a9498ca049469521454832ad1fbf_G_2_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[1];
            float _Split_e550a9498ca049469521454832ad1fbf_B_3_Float = 0;
            float _Split_e550a9498ca049469521454832ad1fbf_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3 = float3(_Split_e550a9498ca049469521454832ad1fbf_R_1_Float, 0, _Split_e550a9498ca049469521454832ad1fbf_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float.xxx), _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3;
            Unity_Add_float3(_Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_R_1_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[0];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_G_2_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[1];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_B_3_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[2];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3, (_Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float.xxx), _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3, _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3, (_Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float.xxx), _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[0];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_G_2_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[1];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[2];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4;
            float3 _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3;
            float2 _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2;
            Unity_Combine_float(_Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float, _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float, 0, 0, _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4, _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3, _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.tex, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.samplerstate, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.GetTransformedUV(_Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_A_8_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4;
            float3 _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3;
            float2 _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float, 0, _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4, _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3;
            Unity_Add_float3(_Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_70940dc414e9445798faf654716fdba6_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3, (_Property_70940dc414e9445798faf654716fdba6_Out_0_Float.xxx), _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float;
            Unity_Multiply_float_float(_Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3, (_Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float.xxx), _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_R_1_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[0];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[1];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_B_3_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[2];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3;
            Unity_Add_float3(_Add_cd114e704768447cb940749c137d5804_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean, _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3;
            Unity_Add_float3(_Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            Unity_Branch_float3(_Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3, _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3, _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            #else
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean = _Use_Texture_as_Alpha;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emission_Flipbook);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.tex, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.samplerstate, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.GetTransformedUV((_UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4.xy)) );
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.r;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.g;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.b;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_A_7_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float, _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float;
            Unity_Add_float(_Add_21f4fac385494c629ba6655c03978c51_Out_2_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float, _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float;
            Unity_Multiply_float_float(_Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float, 0.33, _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float, _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float, _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            Unity_Saturate_float(_Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float, _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            Unity_Branch_float(_Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean, _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float, 1, _Branch_6088271999854d34a90750407a8401a3_Out_3_Float);
            #endif
            surface.Alpha = _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            surface.AlphaClipThreshold = 0.5;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
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
        #pragma shader_feature_local _ USE_WIND_ON
        
        #if defined(USE_TRANSPARENCY_INTERSECTION_ON) && defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_TRANSPARENCY_INTERSECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_WIND_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
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
            output.positionWS = input.positionWS.xyz;
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
        float4 _Emission_Flipbook_TexelSize;
        float _Use_Texture_as_Alpha;
        float _Alpha_Multiplier;
        float _Emission_Intensity;
        float _Wind_from_Center_T_Age_F;
        float _Gust_Strength;
        float _Shiver_Strength;
        float _Bend_Strength;
        float _Intersection_Offset;
        float4 _Emission_Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Emission_Flipbook);
        SAMPLER(sampler_Emission_Flipbook);
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
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_053b93d341c54017acdcf5ca085ba201_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_053b93d341c54017acdcf5ca085ba201_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_053b93d341c54017acdcf5ca085ba201_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_053b93d341c54017acdcf5ca085ba201_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_910afe74b35d4bea90313d0d57c29fb5_R_1_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[0];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_G_2_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[1];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[2];
            float _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float = _UV_a76018e287ec4418a5413193f892390e_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[0];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_G_2_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[1];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[2];
            float _Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float = _UV_1620b881e6d64a31aa9e04c6ea21c565_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float;
            Unity_Multiply_float_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, 0.5, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float;
            Unity_Subtract_float(_Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Multiply_42097e5e6a3e4e409729b988926db705_Out_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Split_053b93d341c54017acdcf5ca085ba201_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Property_319b5d499b11413798b70c730d8ad7b6_Out_0_Float, 0, _Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float;
            Unity_Branch_float(_Property_aebcaf587be14fed8f0ba90926ddaf25_Out_0_Boolean, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Split_910afe74b35d4bea90313d0d57c29fb5_A_4_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3 = float3(_Split_910afe74b35d4bea90313d0d57c29fb5_B_3_Float, _Branch_76971fdbb3484ce6a4407fc139039503_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_R_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3;
            _Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3 = TransformObjectToWorld(_Vector3_55bc2b3bb47947bf81fb84adc2c54e24_Out_0_Vector3.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float = WIND_SETTINGS_GustSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_693a4b1c7823487fa2f6872603d84564_Out_0_Vector3, (_Property_2b929fc1f51243f78e3f341e14860d4d_Out_0_Float.xxx), _Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_7f690e37d2c8499c9cc92fd0b22a1ea1_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3;
            Unity_Subtract_float3(_Transform_579e42905a3a4bfbb822a7cc4617fd60_Out_1_Vector3, _Multiply_c9e0de4da80e4548bbdc6a31b4ed44f3_Out_2_Vector3, _Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_92de9af0229e4016afc0dad754327a92_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_f125f94c3e254b0690af032ba3e728b3_Out_2_Vector3, (_Property_92de9af0229e4016afc0dad754327a92_Out_0_Float.xxx), _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[0];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_G_2_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[1];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float = _Multiply_447b2d1433aa4fdf94e4bab27a7aa99a_Out_2_Vector3[2];
            float _Split_9a25ddaedf8347dd96aab08c72dc9795_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4;
            float3 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3;
            float2 _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2;
            Unity_Combine_float(_Split_9a25ddaedf8347dd96aab08c72dc9795_R_1_Float, _Split_9a25ddaedf8347dd96aab08c72dc9795_B_3_Float, 0, 0, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGBA_4_Vector4, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RGB_5_Vector3, _Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.tex, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.samplerstate, _Property_e38c438e07514f4e81b1ff1a6bfbced1_Out_0_Texture2D.GetTransformedUV(_Combine_63d5dc0fe3f24a7e92517c6bc0f35ec4_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_G_6_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_B_7_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_A_8_Float = _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float;
            Unity_Branch_float(_Comparison_f0c56ec641ea4db296b47314f778c7fb_Out_2_Boolean, _SampleTexture2DLOD_02d7b714b8de4cad9413739161afac6d_R_5_Float, 0, _Branch_924e9783007548e1adfe644e2a385413_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float;
            Unity_Absolute_float(_Branch_924e9783007548e1adfe644e2a385413_Out_3_Float, _Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float;
            Unity_Power_float(_Absolute_2986dc4c2c6949a1aa9954d3e1e7acde_Out_1_Float, 2, _Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float = WIND_SETTINGS_GustScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float;
            Unity_Multiply_float_float(_Power_7c1e5d5c9dae41aaa087097710b8019b_Out_2_Float, _Property_5a31c62e6cc2411a8f57a079c909d522_Out_0_Float, _Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[0];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_G_2_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[1];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[2];
            float _Split_5386e96ec4c8431ebce347e93328fe6a_A_4_Float = _Property_15b97986de38451a8e0d1b1335e04f9b_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2 = float2(_Split_5386e96ec4c8431ebce347e93328fe6a_R_1_Float, _Split_5386e96ec4c8431ebce347e93328fe6a_B_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_7f979362cf5546918a12aded783bbac5_Out_0_Float = _Gust_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean = _Wind_from_Center_T_Age_F;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_e5b1fb1c81ad4191899fcb448f7b587a_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float;
            Unity_Subtract_float(_Split_e5b1fb1c81ad4191899fcb448f7b587a_G_2_Float, _Subtract_0c57cb8723734dc19c9bee488b908a06_Out_2_Float, _Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float;
            Unity_Clamp_float(_Subtract_6ac461b4e3924536b1a04902d0a9d329_Out_2_Float, 0.0001, 1000, _Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float;
            Unity_Divide_float(_Clamp_19a1b7ebc758455fad085eaeda82e7dd_Out_3_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float;
            Unity_Absolute_float(_Divide_79eb0c480b414a4985a0fa3b161c8cef_Out_2_Float, _Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float;
            Unity_Power_float(_Absolute_df946080c325491bb882347a3a61b4ca_Out_1_Float, _Property_8c9ba78eb64d457e813db72f4b256237_Out_0_Float, _Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float;
            Unity_Multiply_float_float(_Power_9a76b6ac5cd04b0990704595c68499b7_Out_2_Float, _Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float;
            Unity_Absolute_float(_Split_aaa89768122741eb9c9fbf5f188d5164_A_4_Float, _Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float = _Bend_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float;
            Unity_Power_float(_Absolute_b45a32bd97354b64b73909a06e0f5cce_Out_1_Float, _Property_1009d6c2f37c4403bc63017f0b63edc1_Out_0_Float, _Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float;
            Unity_SquareRoot_float(_Split_aaa89768122741eb9c9fbf5f188d5164_B_3_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float;
            Unity_Multiply_float_float(_Power_4f9e62bef6814a4fa9d3eb10f3c56a2d_Out_2_Float, _SquareRoot_655cf5cb153b4c4fba7a9aa2dbcc2a70_Out_1_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float;
            Unity_Branch_float(_Property_98864462e0ef494cb3a51bb0c2fc2786_Out_0_Boolean, _Multiply_b990a64dbf674376aa67a4fa010f5758_Out_2_Float, _Multiply_9e5a3db8aa86411f9bbc3d014039ec02_Out_2_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float;
            Unity_Multiply_float_float(_Property_7f979362cf5546918a12aded783bbac5_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_37e8bf7b34164166b2cd74ce9422437f_Out_0_Vector2, (_Multiply_f12542900fcc4c76a35edaf4091718e2_Out_2_Float.xx), _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e550a9498ca049469521454832ad1fbf_R_1_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[0];
            float _Split_e550a9498ca049469521454832ad1fbf_G_2_Float = _Multiply_cb1decbea10242fcb3920b544cb35fe3_Out_2_Vector2[1];
            float _Split_e550a9498ca049469521454832ad1fbf_B_3_Float = 0;
            float _Split_e550a9498ca049469521454832ad1fbf_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3 = float3(_Split_e550a9498ca049469521454832ad1fbf_R_1_Float, 0, _Split_e550a9498ca049469521454832ad1fbf_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_c54d791969c647d3a1d7a55bf50ad89e_Out_2_Float.xxx), _Vector3_762ff644ebf84f5c9d2a5eef2078e8ff_Out_0_Vector3, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3;
            Unity_Add_float3(_Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Add_cd114e704768447cb940749c137d5804_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3 = float3(1, 0, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_R_1_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[0];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_G_2_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[1];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_B_3_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[2];
            float _Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float = _Property_80553d28c2274723bc767446d8b8c416_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_2f410f1f30d34f6e980bb18bbb5a7b23_Out_0_Vector3, (_Split_83eb5189f1794b5897d8a05e8f78a6a4_A_4_Float.xxx), _Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_6e0539c917fa454ea03703995309acc0_Out_2_Vector3, (IN.TimeParameters.x.xxx), _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_e6efdf5713e6498bb3b6bd95fb2504a8_Out_2_Vector3, _Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float = WIND_SETTINGS_ShiverNoiseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Subtract_e334e44e14574262b4a1aafddff9bdde_Out_2_Vector3, (_Property_c2d3cac7ffdd452c9a99265070491d1d_Out_0_Float.xxx), _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[0];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_G_2_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[1];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float = _Multiply_3e4f0777c1064514839ab534f4081a19_Out_2_Vector3[2];
            float _Split_5cc5d380b8b542a9aa414b04e31f4fc9_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4;
            float3 _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3;
            float2 _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2;
            Unity_Combine_float(_Split_5cc5d380b8b542a9aa414b04e31f4fc9_R_1_Float, _Split_5cc5d380b8b542a9aa414b04e31f4fc9_B_3_Float, 0, 0, _Combine_8e6702e470a1431597a781b5fad7389b_RGBA_4_Vector4, _Combine_8e6702e470a1431597a781b5fad7389b_RGB_5_Vector3, _Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.tex, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.samplerstate, _Property_711dd0a019124373806ea4cd0ead1472_Out_0_Texture2D.GetTransformedUV(_Combine_8e6702e470a1431597a781b5fad7389b_RG_6_Vector2), 3);
            #endif
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_A_8_Float = _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4;
            float3 _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3;
            float2 _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_R_5_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_G_6_Float, _SampleTexture2DLOD_a7ce1dedf99d4f9fb6f656fe617f74ba_B_7_Float, 0, _Combine_317ee724efd04ebea45c883b40eb63dd_RGBA_4_Vector4, _Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, _Combine_317ee724efd04ebea45c883b40eb63dd_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3;
            Unity_Add_float3(_Combine_317ee724efd04ebea45c883b40eb63dd_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_70940dc414e9445798faf654716fdba6_Out_0_Float = WIND_SETTINGS_Turbulence;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_ab8b41211dac4a218aab201320128899_Out_2_Vector3, (_Property_70940dc414e9445798faf654716fdba6_Out_0_Float.xxx), _Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float = _Shiver_Strength;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float;
            Unity_Multiply_float_float(_Property_21aa90d268b241228315ec9e19ab784e_Out_0_Float, _Branch_d0ce7b0190094812b7e7aee2463c2a19_Out_3_Float, _Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_4aea49aaf5d34b778eeff4dbb997f7b9_Out_2_Vector3, (_Multiply_1f4089eb1cff4f2daaa768199405079d_Out_2_Float.xxx), _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_R_1_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[0];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[1];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_B_3_Float = _Multiply_07debcd9cc404a7baa3d7ff4442cbc64_Out_2_Vector3[2];
            float _Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3;
            Unity_Add_float3(_Add_cd114e704768447cb940749c137d5804_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3;
            Unity_Branch_float3(_Comparison_c5190a94231a4f13b79225d4db5feabf_Out_2_Boolean, _Add_b38a787750854807a706609e87089ff3_Out_2_Vector3, IN.AbsoluteWorldSpacePosition, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_32f0daac15a44c128b3db835220b9995_Out_2_Vector3, _Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3;
            Unity_Add_float3(_Add_f7d6689fb46d4901800c3124b8258adf_Out_2_Vector3, (_Split_b8033ada4f9d4776ad4d2b3a8c1e4f7f_G_2_Float.xxx), _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            Unity_Branch_float3(_Property_df686f2143814812913ecc432f9c152b_Out_0_Boolean, _Branch_b9b2aef2a95440c4a0738de8c8755fee_Out_3_Vector3, _Add_d2a1a07d64874df591c237f1fdfdab44_Out_2_Vector3, _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_WIND_ON)
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = _Branch_26bd766fb7984876860ed5a1d15151c0_Out_3_Vector3;
            #else
            float3 _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3 = IN.AbsoluteWorldSpacePosition;
            #endif
            #endif
            description.Position = _UseWind_2930f210714c4e33be2597c28befa500_Out_0_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean = _Use_Texture_as_Alpha;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float = _Intersection_Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_02f3652a6ef44e13b448bc9107934aa5_Out_1_Float, _ProjectionParams.z, _Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_093b6b23238f44ad838c7c5a31908591_R_1_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[0];
            float _Split_093b6b23238f44ad838c7c5a31908591_G_2_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[1];
            float _Split_093b6b23238f44ad838c7c5a31908591_B_3_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[2];
            float _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float = _ScreenPosition_1030361c969d498abed07cc11fcbbd28_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float;
            Unity_Subtract_float(_Multiply_fb9c1fa00e2c4308b99deb2720547a73_Out_2_Float, _Split_093b6b23238f44ad838c7c5a31908591_A_4_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float;
            Unity_Multiply_float_float(_Property_63e5c53a54c9425ca5dd41d50122c66e_Out_0_Float, _Subtract_5182dd247c2746bf9fe94421c2d7103e_Out_2_Float, _Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float;
            Unity_Clamp_float(_Multiply_1e6ab4c80b264aeb8dc92a83adbf6cba_Out_2_Float, 0, 1, _Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emission_Flipbook);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.tex, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.samplerstate, _Property_167d742c9f1a4140a88ccb78bc5e2de6_Out_0_Texture2D.GetTransformedUV((_UV_5235c121952c46d5aeafebb40561bccc_Out_0_Vector4.xy)) );
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.r;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.g;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.b;
            float _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_A_7_Float = _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_R_4_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_G_5_Float, _Add_21f4fac385494c629ba6655c03978c51_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float;
            Unity_Add_float(_Add_21f4fac385494c629ba6655c03978c51_Out_2_Float, _SampleTexture2D_d3939cbc3587491483aa8d3c52f16f24_B_6_Float, _Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float;
            Unity_Multiply_float_float(_Add_52881bc848db4ca5a53991665b1bd372_Out_2_Float, 0.33, _Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float = _Alpha_Multiplier;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_26200820010b4d7090eb1616a6952f2c_Out_2_Float, _Property_97e59915a6144301ba44d27330ab524b_Out_0_Float, _Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            Unity_Saturate_float(_Multiply_2548eb9244e646cfb3569063a6d66fad_Out_2_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_df9545ba876e40b9ba359293af80b24f_Out_3_Float, _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float, _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_TRANSPARENCY_INTERSECTION_ON)
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Multiply_de27e482929a494ebafe66fb5a9ae219_Out_2_Float;
            #else
            float _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float = _Saturate_8ea30515c4bc40fead8c547a954ef97f_Out_1_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            Unity_Branch_float(_Property_3a549e66f0814276a244bb8ce2d351d1_Out_0_Boolean, _UseTransparencyIntersection_6a56fafdad1247c1a5a0de4f4cd925d9_Out_0_Float, 1, _Branch_6088271999854d34a90750407a8401a3_Out_3_Float);
            #endif
            surface.Alpha = _Branch_6088271999854d34a90750407a8401a3_Out_3_Float;
            surface.AlphaClipThreshold = 0.5;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
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
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
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