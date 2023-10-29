// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BloodAndMeat/LWRPSurfaceDecal"
{
    Properties
    {
		_BloodAlbedo("BloodAlbedo", 2D) = "white" {}
		_NormalMapBlood("NormalMapBlood", 2D) = "bump" {}
		_Distance("Distance", Float) = 0
		_SizeBlood_("SizeBlood_", Range( 0 , 1)) = 0
		_GlossBlood("GlossBlood", Range( 0 , 1)) = 0
		_MaxDistanceDecal("MaxDistanceDecal", Float) = 100
		_MaskHeight("MaskHeight", Float) = 0
		_Albedo("Albedo", 2D) = "white" {}
		_Spec("Spec", 2D) = "black" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Height("Height", 2D) = "black" {}
		_AO("AO", 2D) = "white" {}
		_LinearToGamma("LinearToGamma", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

    }


    SubShader
    {
		LOD 0

		
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
        Pass
        {
			
        	Tags { "LightMode"="LightweightForward" }

        	Name "Base"
			Blend One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
            
        	HLSLPROGRAM
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #define ASE_FOG 1
            #define ASE_SRP_VERSION 60900
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP 1

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
		
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"


			sampler2D _Albedo;
			float4 BloodPointArray[40];
			half LengthArray;
			sampler2D _BloodAlbedo;
			sampler2D _Height;
			sampler2D _NormalMap;
			sampler2D _NormalMapBlood;
			sampler2D _Spec;
			sampler2D _AO;
			CBUFFER_START( UnityPerMaterial )
			float4 _Albedo_ST;
			float _LinearToGamma;
			float _SizeBlood_;
			float _Distance;
			float _MaxDistanceDecal;
			float4 _Height_ST;
			float _MaskHeight;
			float4 _NormalMap_ST;
			float4 _NormalMapBlood_ST;
			float4 _Spec_ST;
			float _GlossBlood;
			float4 _AO_ST;
			CBUFFER_END


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                float4 lightmapUVOrVertexSH	  : TEXCOORD0;
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;
				float4 tSpace0					: TEXCOORD3;
				float4 tSpace1					: TEXCOORD4;
				float4 tSpace2					: TEXCOORD5;
				float4 ase_texcoord7 : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };

			float4 MyCustomExpression23_g1( float3 WorldPos , float SizeBlood , float Array , int LengthArr , float MaxDist , sampler2D _BloodTexture_ , float4 _BackColor , float3 WorldNormal , float MaxDistance , float CameraPos )
			{
				float Distance = distance(CameraPos,WorldPos);
							half4 Final = _BackColor;
							if (Distance < MaxDistance) {
							float3 projNormal = ( pow( abs( WorldNormal ), 1 ) );
										float3 nsign = sign( WorldNormal );
																									
																									for (int i = 0;i < LengthArr;i++) {
																										float dist_ = distance(float4( WorldPos , 0.0 ),BloodPointArray[i]);
																										if (dist_ < MaxDist) {
																									float2 _uv_x = ( ( (WorldPos).zy * SizeBlood ) + ( float2( 0.5,0.5 ) - ( BloodPointArray[i].zy * SizeBlood ) ) );
																									float2 _uv_y = ( ( (WorldPos).xz * SizeBlood ) + ( float2( 0.5,0.5 ) - ( BloodPointArray[i].xz * SizeBlood ) ) );
																									float2 _uv_z = ( ( (WorldPos).xy * SizeBlood ) + ( float2( 0.5,0.5 ) - ( BloodPointArray[i].xy * SizeBlood ) ) );
																									
												                        	float cos43 = cos( BloodPointArray[i].a );
												                         	float sin43 = sin( BloodPointArray[i].a );
												                        	float2 rotatorX = mul( _uv_x - float2( 0.5,0.5 ), float2x2( cos43 , -sin43 , sin43 , cos43 )) + float2( 0.5,0.5 );
																			float2 rotatorY = mul( _uv_y - float2( 0.5,0.5 ), float2x2( cos43 , -sin43 , sin43 , cos43 )) + float2( 0.5,0.5 );
																			float2 rotatorZ = mul( _uv_z - float2( 0.5,0.5 ), float2x2( cos43 , -sin43 , sin43 , cos43 )) + float2( 0.5,0.5 );
																						half4 tX = 0;
																						half4 tY = 0;
																						half4 tZ = 0;
																									if (rotatorX.x < 1 && rotatorX.x > 0 && rotatorX.y < 1 && rotatorX.y > 0) {
																						
																						tX = tex2D(_BloodTexture_,rotatorX * float2( nsign.x, 1.0 ));
																									}
							if (rotatorY.x < 1 && rotatorY.x > 0 && rotatorY.y < 1 && rotatorY.y > 0) {
																						tY = tex2D(_BloodTexture_,rotatorY * float2( nsign.y, 1.0 ));
							}
							if (rotatorZ.x < 1 && rotatorZ.x > 0 && rotatorZ.y < 1 && rotatorZ.y > 0) {
																						tZ = tex2D(_BloodTexture_,rotatorZ * float2( -nsign.z, 1.0 ));
							}
																						half4 tt_ = tX * projNormal.x + tY * projNormal.y + tZ * projNormal.z;
																						
													                     	Final.a += tt_.a;
																			Final = lerp(Final,tt_,tt_.a);
																			
																										}
																									}
							}
																									return Final;
			}
			

            GraphVertexOutput vert (GraphVertexInput v  )
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal =  v.ase_normal ;

        		// Vertex shader outputs defined by graph
                float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
        	    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
			#ifdef ASE_FOG
        	    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
			#else
				half fogFactor = 0;
			#endif
        	    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN  ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

        		float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );
    
				float2 uv_Albedo = IN.ase_texcoord7.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
				float3 linearToGamma59 = FastLinearToSRGB( tex2DNode1.rgb );
				float4 lerpResult60 = lerp( tex2DNode1 , float4( linearToGamma59 , 0.0 ) , _LinearToGamma);
				float3 WorldPos23_g1 = WorldSpacePosition;
				float SizeBlood23_g1 = ( 1.0 - _SizeBlood_ );
				float Array23_g1 = BloodPointArray[0].x;
				int LengthArr23_g1 = (int)LengthArray;
				float MaxDist23_g1 = _Distance;
				sampler2D _BloodTexture_23_g1 = _BloodAlbedo;
				float4 _BackColor23_g1 = float4( 0,0,0,0 );
				float3 WorldNormal23_g1 = WorldSpaceNormal;
				float MaxDistance23_g1 = _MaxDistanceDecal;
				float CameraPos23_g1 = _WorldSpaceCameraPos.x;
				float4 localMyCustomExpression23_g1 = MyCustomExpression23_g1( WorldPos23_g1 , SizeBlood23_g1 , Array23_g1 , LengthArr23_g1 , MaxDist23_g1 , _BloodTexture_23_g1 , _BackColor23_g1 , WorldNormal23_g1 , MaxDistance23_g1 , CameraPos23_g1 );
				float4 temp_output_35_0 = localMyCustomExpression23_g1;
				float2 uv_Height = IN.ase_texcoord7.xy * _Height_ST.xy + _Height_ST.zw;
				float4 lerpResult73 = lerp( pow( temp_output_35_0 , 3.0 ) , temp_output_35_0 , ( tex2D( _Height, uv_Height ).r * _MaskHeight ));
				float temp_output_40_0 = (temp_output_35_0).w;
				float4 lerpResult39 = lerp( lerpResult60 , lerpResult73 , temp_output_40_0);
				
				float2 uv_NormalMap = IN.ase_texcoord7.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 tex2DNode46 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), 1.0f );
				float2 uv_NormalMapBlood = IN.ase_texcoord7.xy * _NormalMapBlood_ST.xy + _NormalMapBlood_ST.zw;
				float3 lerpResult68 = lerp( tex2DNode46 , BlendNormal( tex2DNode46 , UnpackNormalScale( tex2D( _NormalMapBlood, uv_NormalMapBlood ), 1.0f ) ) , temp_output_40_0);
				
				float2 uv_Spec = IN.ase_texcoord7.xy * _Spec_ST.xy + _Spec_ST.zw;
				float4 tex2DNode47 = tex2D( _Spec, uv_Spec );
				
				float blendOpSrc50 = tex2DNode47.a;
				float blendOpDest50 = ( temp_output_40_0 * _GlossBlood );
				
				float2 uv_AO = IN.ase_texcoord7.xy * _AO_ST.xy + _AO_ST.zw;
				
				
		        float3 Albedo = lerpResult39.xyz;
				float3 Normal = lerpResult68;
				float3 Emission = 0;
				float3 Specular = tex2DNode47.rgb;
				float Metallic = 0;
				float Smoothness = ( saturate( 2.0f*blendOpDest50*blendOpSrc50 + blendOpDest50*blendOpDest50*(1.0f - 2.0f*blendOpSrc50) ));
				float Occlusion = tex2D( _AO, uv_AO ).r;
				float Alpha = 1;
				float AlphaClipThreshold = 0;

        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;

        #ifdef _NORMALMAP
        	    inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
        #else
            #if !SHADER_HINT_NICE_QUALITY
                inputData.normalWS = WorldSpaceNormal;
            #else
        	    inputData.normalWS = normalize(WorldSpaceNormal);
            #endif
        #endif

			#if !SHADER_HINT_NICE_QUALITY
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
			#else
        	    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
			#endif

        	    inputData.shadowCoord = IN.shadowCoord;
			#ifdef ASE_FOG
        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
			#endif
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);

        		half4 color = LightweightFragmentPBR(
        			inputData, 
        			Albedo, 
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

		#ifdef ASE_FOG
			#ifdef TERRAIN_SPLAT_ADDPASS
				color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
			#else
				color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
			#endif
		#endif

        #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

		#if ASE_LW_FINAL_COLOR_ALPHA_MULTIPLY
				color.rgb *= color.a;
		#endif
		
		#ifdef LOD_FADE_CROSSFADE
				LODDitheringTransition (IN.clipPos.xyz, unity_LODFade.x);
		#endif
        		return color;
            }

        	ENDHLSL
        }

		
        Pass
        {
			
        	Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

            HLSLPROGRAM
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #define ASE_FOG 1
            #define ASE_SRP_VERSION 60900

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			CBUFFER_START( UnityPerMaterial )
			float4 _Albedo_ST;
			float _LinearToGamma;
			float _SizeBlood_;
			float _Distance;
			float _MaxDistanceDecal;
			float4 _Height_ST;
			float _MaskHeight;
			float4 _NormalMap_ST;
			float4 _NormalMapBlood_ST;
			float4 _Spec_ST;
			float _GlossBlood;
			float4 _AO_ST;
			CBUFFER_END


        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
        	};

			
            // x: global clip space bias, y: normal world space bias
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v )
        	{
        	    VertexOutput o;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO (o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;

        	    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;

                // normal bias is negative since we want to apply an inset normal offset
                positionWS = _LightDirection * _ShadowBias.xxx + positionWS;
				positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);

                // _ShadowBias.x sign depens on if platform has reversed z buffer
                //clipPos.z += _ShadowBias.x;

        	#if UNITY_REVERSED_Z
        	    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#else
        	    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#endif
                o.clipPos = clipPos;

        	    return o;
        	}

            half4 ShadowPassFragment(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

               

				float Alpha = 1;
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

		#ifdef LOD_FADE_CROSSFADE
				LODDitheringTransition (IN.clipPos.xyz, unity_LODFade.x);
		#endif
				return 0;
            }

            ENDHLSL
        }

		
        Pass
        {
			
        	Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }

            ZWrite On
			ColorMask 0

            HLSLPROGRAM
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #define ASE_FOG 1
            #define ASE_SRP_VERSION 60900

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            

			CBUFFER_START( UnityPerMaterial )
			float4 _Albedo_ST;
			float _LinearToGamma;
			float _SizeBlood_;
			float _Distance;
			float _MaxDistanceDecal;
			float4 _Height_ST;
			float _MaskHeight;
			float4 _NormalMap_ST;
			float4 _NormalMapBlood_ST;
			float4 _Spec_ST;
			float _GlossBlood;
			float4 _AO_ST;
			CBUFFER_END


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

			           

            VertexOutput vert(GraphVertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

				

				float Alpha = 1;
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
		#ifdef LOD_FADE_CROSSFADE
				LODDitheringTransition (IN.clipPos.xyz, unity_LODFade.x);
		#endif
				return 0;
            }
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
		
        Pass
        {
			
        	Name "Meta"
            Tags { "LightMode"="Meta" }

            Cull Off

            HLSLPROGRAM
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #define ASE_FOG 1
            #define ASE_SRP_VERSION 60900

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex vert
            #pragma fragment frag

			
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"


			sampler2D _Albedo;
			float4 BloodPointArray[40];
			half LengthArray;
			sampler2D _BloodAlbedo;
			sampler2D _Height;
			CBUFFER_START( UnityPerMaterial )
			float4 _Albedo_ST;
			float _LinearToGamma;
			float _SizeBlood_;
			float _Distance;
			float _MaxDistanceDecal;
			float4 _Height_ST;
			float _MaskHeight;
			float4 _NormalMap_ST;
			float4 _NormalMapBlood_ST;
			float4 _Spec_ST;
			float _GlossBlood;
			float4 _AO_ST;
			CBUFFER_END


            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_texcoord1 : TEXCOORD1;
                float4 ase_texcoord2 : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

			float4 MyCustomExpression23_g1( float3 WorldPos , float SizeBlood , float Array , int LengthArr , float MaxDist , sampler2D _BloodTexture_ , float4 _BackColor , float3 WorldNormal , float MaxDistance , float CameraPos )
			{
				float Distance = distance(CameraPos,WorldPos);
							half4 Final = _BackColor;
							if (Distance < MaxDistance) {
							float3 projNormal = ( pow( abs( WorldNormal ), 1 ) );
										float3 nsign = sign( WorldNormal );
																									
																									for (int i = 0;i < LengthArr;i++) {
																										float dist_ = distance(float4( WorldPos , 0.0 ),BloodPointArray[i]);
																										if (dist_ < MaxDist) {
																									float2 _uv_x = ( ( (WorldPos).zy * SizeBlood ) + ( float2( 0.5,0.5 ) - ( BloodPointArray[i].zy * SizeBlood ) ) );
																									float2 _uv_y = ( ( (WorldPos).xz * SizeBlood ) + ( float2( 0.5,0.5 ) - ( BloodPointArray[i].xz * SizeBlood ) ) );
																									float2 _uv_z = ( ( (WorldPos).xy * SizeBlood ) + ( float2( 0.5,0.5 ) - ( BloodPointArray[i].xy * SizeBlood ) ) );
																									
												                        	float cos43 = cos( BloodPointArray[i].a );
												                         	float sin43 = sin( BloodPointArray[i].a );
												                        	float2 rotatorX = mul( _uv_x - float2( 0.5,0.5 ), float2x2( cos43 , -sin43 , sin43 , cos43 )) + float2( 0.5,0.5 );
																			float2 rotatorY = mul( _uv_y - float2( 0.5,0.5 ), float2x2( cos43 , -sin43 , sin43 , cos43 )) + float2( 0.5,0.5 );
																			float2 rotatorZ = mul( _uv_z - float2( 0.5,0.5 ), float2x2( cos43 , -sin43 , sin43 , cos43 )) + float2( 0.5,0.5 );
																						half4 tX = 0;
																						half4 tY = 0;
																						half4 tZ = 0;
																									if (rotatorX.x < 1 && rotatorX.x > 0 && rotatorX.y < 1 && rotatorX.y > 0) {
																						
																						tX = tex2D(_BloodTexture_,rotatorX * float2( nsign.x, 1.0 ));
																									}
							if (rotatorY.x < 1 && rotatorY.x > 0 && rotatorY.y < 1 && rotatorY.y > 0) {
																						tY = tex2D(_BloodTexture_,rotatorY * float2( nsign.y, 1.0 ));
							}
							if (rotatorZ.x < 1 && rotatorZ.x > 0 && rotatorZ.y < 1 && rotatorZ.y > 0) {
																						tZ = tex2D(_BloodTexture_,rotatorZ * float2( -nsign.z, 1.0 ));
							}
																						half4 tt_ = tX * projNormal.x + tY * projNormal.y + tZ * projNormal.z;
																						
													                     	Final.a += tt_.a;
																			Final = lerp(Final,tt_,tt_.a);
																			
																										}
																									}
							}
																									return Final;
			}
			

            VertexOutput vert(GraphVertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;
#if !defined( ASE_SRP_VERSION ) || ASE_SRP_VERSION  > 51300				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST);
#else
				o.clipPos = MetaVertexPosition (v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST);
#endif
        	    return o;
            }

            half4 frag(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float2 uv_Albedo = IN.ase_texcoord.xy * _Albedo_ST.xy + _Albedo_ST.zw;
           		float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
           		float3 linearToGamma59 = FastLinearToSRGB( tex2DNode1.rgb );
           		float4 lerpResult60 = lerp( tex2DNode1 , float4( linearToGamma59 , 0.0 ) , _LinearToGamma);
           		float3 ase_worldPos = IN.ase_texcoord1.xyz;
           		float3 WorldPos23_g1 = ase_worldPos;
           		float SizeBlood23_g1 = ( 1.0 - _SizeBlood_ );
           		float Array23_g1 = BloodPointArray[0].x;
           		int LengthArr23_g1 = (int)LengthArray;
           		float MaxDist23_g1 = _Distance;
           		sampler2D _BloodTexture_23_g1 = _BloodAlbedo;
           		float4 _BackColor23_g1 = float4( 0,0,0,0 );
           		float3 ase_worldNormal = IN.ase_texcoord2.xyz;
           		float3 WorldNormal23_g1 = ase_worldNormal;
           		float MaxDistance23_g1 = _MaxDistanceDecal;
           		float CameraPos23_g1 = _WorldSpaceCameraPos.x;
           		float4 localMyCustomExpression23_g1 = MyCustomExpression23_g1( WorldPos23_g1 , SizeBlood23_g1 , Array23_g1 , LengthArr23_g1 , MaxDist23_g1 , _BloodTexture_23_g1 , _BackColor23_g1 , WorldNormal23_g1 , MaxDistance23_g1 , CameraPos23_g1 );
           		float4 temp_output_35_0 = localMyCustomExpression23_g1;
           		float2 uv_Height = IN.ase_texcoord.xy * _Height_ST.xy + _Height_ST.zw;
           		float4 lerpResult73 = lerp( pow( temp_output_35_0 , 3.0 ) , temp_output_35_0 , ( tex2D( _Height, uv_Height ).r * _MaskHeight ));
           		float temp_output_40_0 = (temp_output_35_0).w;
           		float4 lerpResult39 = lerp( lerpResult60 , lerpResult73 , temp_output_40_0);
           		
				
		        float3 Albedo = lerpResult39.xyz;
				float3 Emission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = 0;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = Albedo;
                metaInput.Emission = Emission;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
        }
		
    }
    
	CustomEditor "ASEMaterialInspector"
	
}
/*ASEBEGIN
Version=17400
0;26;1906;993;833.605;275.471;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;41;-603.3902,29.66184;Float;False;Property;_SizeBlood_;SizeBlood_;3;0;Create;True;0;0;False;0;0;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;42;-327.0636,76.35555;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-682.1304,118.5183;Float;False;Property;_MaxDistanceDecal;MaxDistanceDecal;7;0;Create;True;0;0;False;0;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;36;-727.0029,350.9152;Float;True;Property;_BloodAlbedo;BloodAlbedo;0;0;Create;True;0;0;False;0;None;b6bf872e503816244b41d87116f4fded;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-688.3965,252.6535;Float;False;Property;_Distance;Distance;2;0;Create;True;0;0;False;0;0;23.73;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-395.4806,772.643;Float;False;Property;_MaskHeight;MaskHeight;8;0;Create;True;0;0;False;0;0;3.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;53;-440.4112,490.1281;Inherit;True;Property;_Height;Height;12;0;Create;True;0;0;False;0;-1;None;3c776dc94b18a94459063874e16c2488;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;35;-211.1729,204.8235;Inherit;False;BloodTille;4;;1;97809717ab4fc21409920e256e8523ee;0;4;30;FLOAT;100;False;28;FLOAT;0;False;27;FLOAT;0;False;26;SAMPLER2D;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1;-475.2491,-877.3688;Inherit;True;Property;_Albedo;Albedo;9;0;Create;True;0;0;False;0;-1;None;1dc4e91bafe20d943986e11c4bb982d4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LinearToGammaNode;59;-140.3257,-110.1261;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;290.8105,695.9531;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-108.8707,21.31145;Float;False;Property;_LinearToGamma;LinearToGamma;14;0;Create;True;0;0;False;0;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;69;430.7219,556.1229;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;3;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;695.5389,183.9559;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;210.1293,-75.68855;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;73;765.5074,577.9843;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;68;1521.902,-196.1546;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;66;1036.376,-622.787;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;1559.526,308.8848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;49;130.1682,-344.1298;Inherit;True;Property;_AO;AO;13;0;Create;True;0;0;False;0;-1;None;69f91e2e215f095448fc7ce140f58778;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;47;1372.535,-89.027;Inherit;True;Property;_Spec;Spec;10;0;Create;True;0;0;False;0;-1;None;29401dee1281a4b4584d6a165b3b1865;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;50;1832.924,175.44;Inherit;False;SoftLight;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;1151.487,372.4448;Float;False;Property;_GlossBlood;GlossBlood;6;0;Create;True;0;0;False;0;0;0.85;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;46;-475.7608,-660.1481;Inherit;True;Property;_NormalMap;NormalMap;11;0;Create;True;0;0;False;0;-1;None;7e7585b10b55d5941aea4825fc9f4669;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;67;123.9121,-585.759;Inherit;True;Property;_NormalMapBlood;NormalMapBlood;1;0;Create;True;0;0;False;0;-1;None;5532a7cc72a627343b298d4c452f2e23;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;39;1518.138,-316.9309;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;74;2234.674,23.32288;Float;False;True;-1;2;ASEMaterialInspector;0;2;BloodAndMeat/LWRPSurfaceDecal;1976390536c6c564abb90fe41f6ee334;True;Base;0;0;Base;11;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;;0;0;Standard;4;Vertex Position,InvertActionOnDeselection;1;Receive Shadows;1;LOD CrossFade;1;Built-in Fog;1;1;_FinalColorxAlpha;0;4;True;True;True;True;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;75;2234.674,23.32288;Float;False;False;-1;2;ASEMaterialInspector;0;2;ASETemplateShaders/LightWeight;1976390536c6c564abb90fe41f6ee334;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;76;2234.674,23.32288;Float;False;False;-1;2;ASEMaterialInspector;0;2;ASETemplateShaders/LightWeight;1976390536c6c564abb90fe41f6ee334;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;77;2234.674,53.32288;Float;False;False;-1;2;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;0
WireConnection;42;0;41;0
WireConnection;35;30;72;0
WireConnection;35;28;42;0
WireConnection;35;27;37;0
WireConnection;35;26;36;0
WireConnection;59;0;1;0
WireConnection;57;0;53;1
WireConnection;57;1;58;0
WireConnection;69;0;35;0
WireConnection;40;0;35;0
WireConnection;60;0;1;0
WireConnection;60;1;59;0
WireConnection;60;2;61;0
WireConnection;73;0;69;0
WireConnection;73;1;35;0
WireConnection;73;2;57;0
WireConnection;68;0;46;0
WireConnection;68;1;66;0
WireConnection;68;2;40;0
WireConnection;66;0;46;0
WireConnection;66;1;67;0
WireConnection;51;0;40;0
WireConnection;51;1;52;0
WireConnection;50;0;47;4
WireConnection;50;1;51;0
WireConnection;39;0;60;0
WireConnection;39;1;73;0
WireConnection;39;2;40;0
WireConnection;74;0;39;0
WireConnection;74;1;68;0
WireConnection;74;9;47;0
WireConnection;74;4;50;0
WireConnection;74;5;49;0
ASEEND*/
//CHKSM=1CDB4F865D6918D4A930CB702425F49C292829E9