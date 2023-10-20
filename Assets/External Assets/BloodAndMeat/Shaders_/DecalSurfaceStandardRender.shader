// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BloodAndMeat/StandardSurface"
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
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _NormalMapBlood;
		uniform float4 _NormalMapBlood_ST;
		uniform float _SizeBlood_;
		uniform float4 BloodPointArray[40];
		uniform half LengthArray;
		uniform float _Distance;
		uniform sampler2D _BloodAlbedo;
		uniform float _MaxDistanceDecal;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float _LinearToGamma;
		uniform sampler2D _Height;
		uniform float4 _Height_ST;
		uniform float _MaskHeight;
		uniform sampler2D _Spec;
		uniform float4 _Spec_ST;
		uniform float _GlossBlood;
		uniform sampler2D _AO;
		uniform float4 _AO_ST;


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


		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode46 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float2 uv_NormalMapBlood = i.uv_texcoord * _NormalMapBlood_ST.xy + _NormalMapBlood_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float3 WorldPos23_g1 = ase_worldPos;
			float SizeBlood23_g1 = ( 1.0 - _SizeBlood_ );
			float Array23_g1 = BloodPointArray[0].x;
			int LengthArr23_g1 = (int)LengthArray;
			float MaxDist23_g1 = _Distance;
			sampler2D _BloodTexture_23_g1 = _BloodAlbedo;
			float4 _BackColor23_g1 = float4( 0,0,0,0 );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 WorldNormal23_g1 = ase_worldNormal;
			float MaxDistance23_g1 = _MaxDistanceDecal;
			float CameraPos23_g1 = _WorldSpaceCameraPos.x;
			float4 localMyCustomExpression23_g1 = MyCustomExpression23_g1( WorldPos23_g1 , SizeBlood23_g1 , Array23_g1 , LengthArr23_g1 , MaxDist23_g1 , _BloodTexture_23_g1 , _BackColor23_g1 , WorldNormal23_g1 , MaxDistance23_g1 , CameraPos23_g1 );
			float4 temp_output_35_0 = localMyCustomExpression23_g1;
			float temp_output_40_0 = (temp_output_35_0).w;
			float3 lerpResult68 = lerp( tex2DNode46 , BlendNormals( tex2DNode46 , UnpackNormal( tex2D( _NormalMapBlood, uv_NormalMapBlood ) ) ) , temp_output_40_0);
			o.Normal = lerpResult68;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
			float3 linearToGamma59 = LinearToGammaSpace( tex2DNode1.rgb );
			float4 lerpResult60 = lerp( tex2DNode1 , float4( linearToGamma59 , 0.0 ) , _LinearToGamma);
			float2 uv_Height = i.uv_texcoord * _Height_ST.xy + _Height_ST.zw;
			float4 lerpResult73 = lerp( pow( temp_output_35_0 , 3.0 ) , temp_output_35_0 , ( tex2D( _Height, uv_Height ).r * _MaskHeight ));
			float4 lerpResult39 = lerp( lerpResult60 , lerpResult73 , temp_output_40_0);
			o.Albedo = lerpResult39.xyz;
			float2 uv_Spec = i.uv_texcoord * _Spec_ST.xy + _Spec_ST.zw;
			float4 tex2DNode47 = tex2D( _Spec, uv_Spec );
			o.Specular = tex2DNode47.rgb;
			float blendOpSrc50 = tex2DNode47.a;
			float blendOpDest50 = ( temp_output_40_0 * _GlossBlood );
			o.Smoothness = ( saturate( 2.0f*blendOpDest50*blendOpSrc50 + blendOpDest50*blendOpDest50*(1.0f - 2.0f*blendOpSrc50) ));
			float2 uv_AO = i.uv_texcoord * _AO_ST.xy + _AO_ST.zw;
			o.Occlusion = tex2D( _AO, uv_AO ).r;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15900
7;29;1352;692;1091.953;246.9127;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;41;-603.3902,29.66184;Float;False;Property;_SizeBlood_;SizeBlood_;3;0;Create;True;0;0;False;0;0;0.869;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-688.3965,252.6535;Float;False;Property;_Distance;Distance;2;0;Create;True;0;0;False;0;0;4.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-682.1304,118.5183;Float;False;Property;_MaxDistanceDecal;MaxDistanceDecal;7;0;Create;True;0;0;False;0;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;42;-327.0636,76.35555;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;36;-727.0029,350.9152;Float;True;Property;_BloodAlbedo;BloodAlbedo;0;0;Create;True;0;0;False;0;None;b6bf872e503816244b41d87116f4fded;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;1;-475.2491,-877.3688;Float;True;Property;_Albedo;Albedo;9;0;Create;True;0;0;False;0;None;1dc4e91bafe20d943986e11c4bb982d4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;53;-440.4112,490.1281;Float;True;Property;_Height;Height;12;0;Create;True;0;0;False;0;None;3c776dc94b18a94459063874e16c2488;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-395.4806,772.643;Float;False;Property;_MaskHeight;MaskHeight;8;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;35;-211.1729,204.8235;Float;False;BloodTille;4;;1;97809717ab4fc21409920e256e8523ee;0;4;30;FLOAT;100;False;28;FLOAT;0;False;27;FLOAT;0;False;26;SAMPLER2D;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-108.8707,21.31145;Float;False;Property;_LinearToGamma;LinearToGamma;14;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;1151.487,372.4448;Float;False;Property;_GlossBlood;GlossBlood;6;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LinearToGammaNode;59;-140.3257,-110.1261;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;46;-475.7608,-660.1481;Float;True;Property;_NormalMap;NormalMap;11;0;Create;True;0;0;False;0;None;7e7585b10b55d5941aea4825fc9f4669;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;67;123.9121,-585.759;Float;True;Property;_NormalMapBlood;NormalMapBlood;1;0;Create;True;0;0;False;0;None;5532a7cc72a627343b298d4c452f2e23;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;69;430.7219,556.1229;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;3;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;290.8105,695.9531;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;695.5389,183.9559;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;1559.526,308.8848;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;210.1293,-75.68855;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;66;1036.376,-622.787;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;47;-475.5986,-459.0916;Float;True;Property;_Spec;Spec;10;0;Create;True;0;0;False;0;None;29401dee1281a4b4584d6a165b3b1865;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;73;765.5074,577.9843;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BlendOpsNode;50;1809.924,246.44;Float;False;SoftLight;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;39;1494.677,58.44843;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;49;124.648,-384.7817;Float;True;Property;_AO;AO;13;0;Create;True;0;0;False;0;None;69f91e2e215f095448fc7ce140f58778;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;68;1487.173,-156.5627;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2234.674,23.32288;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;BloodAndMeat/StandardSurface;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;42;0;41;0
WireConnection;35;30;72;0
WireConnection;35;28;42;0
WireConnection;35;27;37;0
WireConnection;35;26;36;0
WireConnection;59;0;1;0
WireConnection;69;0;35;0
WireConnection;57;0;53;1
WireConnection;57;1;58;0
WireConnection;40;0;35;0
WireConnection;51;0;40;0
WireConnection;51;1;52;0
WireConnection;60;0;1;0
WireConnection;60;1;59;0
WireConnection;60;2;61;0
WireConnection;66;0;46;0
WireConnection;66;1;67;0
WireConnection;73;0;69;0
WireConnection;73;1;35;0
WireConnection;73;2;57;0
WireConnection;50;0;47;4
WireConnection;50;1;51;0
WireConnection;39;0;60;0
WireConnection;39;1;73;0
WireConnection;39;2;40;0
WireConnection;68;0;46;0
WireConnection;68;1;66;0
WireConnection;68;2;40;0
WireConnection;0;0;39;0
WireConnection;0;1;68;0
WireConnection;0;3;47;0
WireConnection;0;4;50;0
WireConnection;0;5;49;0
ASEEND*/
//CHKSM=E91976F36E8CEA4E734EF762C3333DC58EEE27F3