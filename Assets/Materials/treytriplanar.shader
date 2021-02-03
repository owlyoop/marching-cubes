// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "treytriplanar"
{
	Properties
	{
		_TriplanarAlbedo("Triplanar Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Metallic("Metallic", 2D) = "white" {}
		_TopAlbedo("Top Albedo", 2D) = "white" {}
		_TopNormal("Top Normal", 2D) = "bump" {}
		_TopMetallic("Top Metallic", 2D) = "white" {}
		_TextureScale("TextureScale", Float) = 1
		[IntRange]_WorldtoObjectSwitch("World to Object Switch", Range( 0 , 1)) = 0
		_CoverageAmount("Coverage Amount", Range( -1 , 1)) = 0
		_CoverageFalloff("Coverage Falloff", Range( 0.01 , 2)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _Normal;
		uniform float _TextureScale;
		uniform sampler2D _TopNormal;
		uniform float _WorldtoObjectSwitch;
		uniform float _CoverageAmount;
		uniform float _CoverageFalloff;
		uniform sampler2D _TriplanarAlbedo;
		uniform sampler2D _TopAlbedo;
		uniform sampler2D _Metallic;
		uniform sampler2D _TopMetallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult23 = (float2(ase_worldPos.y , ase_worldPos.z));
			float TextureScale147 = _TextureScale;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 temp_output_5_0 = abs( mul( unity_WorldToObject, float4( ase_worldNormal , 0.0 ) ).xyz );
			float dotResult6 = dot( temp_output_5_0 , float3(1,1,1) );
			float3 BlendComponents8 = ( temp_output_5_0 / dotResult6 );
			float2 appendResult22 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult21 = (float2(ase_worldPos.x , ase_worldPos.y));
			float3 temp_output_45_0 = ( ( ( UnpackNormal( tex2D( _Normal, ( appendResult23 * TextureScale147 ) ) ) * BlendComponents8.x ) + ( UnpackNormal( tex2D( _Normal, ( appendResult22 * TextureScale147 ) ) ) * BlendComponents8.y ) ) + ( UnpackNormal( tex2D( _Normal, ( appendResult21 * TextureScale147 ) ) ) * BlendComponents8.z ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float WorldObjectSwitch51 = _WorldtoObjectSwitch;
			float3 lerpResult83 = lerp( ase_worldPos , ase_vertex3Pos , WorldObjectSwitch51);
			float3 break91 = lerpResult83;
			float2 appendResult95 = (float2(break91.x , break91.z));
			float2 temp_output_168_0 = ( appendResult95 * TextureScale147 );
			float temp_output_43_0 = pow( saturate( ( ase_worldNormal.y + _CoverageAmount ) ) , _CoverageFalloff );
			float3 lerpResult46 = lerp( temp_output_45_0 , UnpackNormal( tex2D( _TopNormal, temp_output_168_0 ) ) , temp_output_43_0);
			float3 CalculatedNormal47 = lerpResult46;
			o.Normal = CalculatedNormal47;
			float2 appendResult82 = (float2(ase_worldPos.y , ase_worldPos.z));
			float2 appendResult84 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult81 = (float2(ase_worldPos.x , ase_worldPos.y));
			float3 PixelNormal55 = (WorldNormalVector( i , temp_output_45_0 ));
			float3 lerpResult72 = lerp( PixelNormal55 , mul( unity_WorldToObject, float4( PixelNormal55 , 0.0 ) ).xyz , WorldObjectSwitch51);
			float3 temp_cast_4 = (_CoverageFalloff).xxx;
			float4 lerpResult107 = lerp( ( ( ( tex2D( _TriplanarAlbedo, ( appendResult82 * TextureScale147 ) ) * BlendComponents8.x ) + ( tex2D( _TriplanarAlbedo, ( appendResult84 * TextureScale147 ) ) * BlendComponents8.y ) ) + ( tex2D( _TriplanarAlbedo, ( appendResult81 * TextureScale147 ) ) * BlendComponents8.z ) ) , tex2D( _TopAlbedo, temp_output_168_0 ) , pow( saturate( ( lerpResult72 + _CoverageAmount ) ) , temp_cast_4 ).y);
			o.Albedo = lerpResult107.rgb;
			float2 appendResult162 = (float2(ase_worldPos.y , ase_worldPos.z));
			float2 appendResult125 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult123 = (float2(ase_worldPos.x , ase_worldPos.y));
			float4 lerpResult141 = lerp( ( ( ( tex2D( _Metallic, ( appendResult162 * TextureScale147 ) ) * BlendComponents8.x ) + ( tex2D( _Metallic, ( appendResult125 * TextureScale147 ) ) * BlendComponents8.y ) ) + ( tex2D( _Metallic, ( appendResult123 * TextureScale147 ) ) * BlendComponents8.z ) ) , tex2D( _TopMetallic, temp_output_168_0 ) , temp_output_43_0);
			o.Metallic = lerpResult141.r;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
Version=18703
0;0;1920;1019;611.9344;-437.192;1;True;True
Node;AmplifyShaderEditor.WorldToObjectMatrix;1;-2942.525,-1193.042;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-2942.525,-1097.042;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2670.525,-1129.042;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;5;-2510.525,-1129.042;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;4;-2543.643,-948.5916;Float;False;Constant;_Vector0;Vector 0;-1;0;Create;True;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;6;-2336.625,-1062.644;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;-2174.525,-1129.042;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-2200.9,-1515.821;Inherit;False;Property;_TextureScale;TextureScale;6;0;Create;True;0;0;False;0;False;1;0.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-2014.525,-1129.042;Float;True;BlendComponents;1;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;177;-1652.659,569.5168;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;178;-1699.462,849.5963;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;9;-2316.371,994.5037;Inherit;False;8;BlendComponents;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-1919.176,-1513.092;Float;False;TextureScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;179;-1681.328,1163.246;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;14;-1980.371,1138.503;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;154;-1445.097,701.8995;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-1473.937,872.9346;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;11;-1980.371,850.5037;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;156;-1494.89,985.3406;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-1426.937,594.9342;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-1492.071,1189.465;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-1504.556,1298.131;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;17;-1708.371,1314.503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-1288.494,879.2576;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-1287.16,1190.048;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-1276.701,598.8165;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;19;-1708.371,802.5037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-1150.373,873.5037;Inherit;True;Property;_TextureSample4;Texture Sample 4;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Instance;24;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;25;-1980.371,994.5037;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;24;-1147.373,588.5031;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;False;0;False;-1;None;f1f5f9dada5ebb1438b0bc6b1fdc924f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;29;-1128.373,1162.503;Inherit;True;Property;_TextureSample5;Texture Sample 5;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Instance;24;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;32;-1676.371,1346.503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;26;-1676.371,770.5037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-812.3728,722.5037;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-812.3728,1298.503;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-812.3728,994.5037;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-572.3722,834.5037;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;42;-588.3723,1138.503;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1326.525,-361.0415;Float;False;Property;_WorldtoObjectSwitch;World to Object Switch;7;1;[IntRange];Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-332.3719,1026.504;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;49;868.7148,1210.63;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-990.8329,-363.9465;Float;False;WorldObjectSwitch;4;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1195.234,-259.9146;Inherit;False;436.2993;336.8007;Coverage in Object mode;3;59;56;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;53;-1710.525,-1001.042;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;60;-606.5253,-857.0415;Inherit;False;224;239;Coverage in World mode;1;73;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;62;-700.5048,-564.7816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-606.5253,-585.0415;Inherit;False;235.9301;237.3099;Coverage in Object mode;1;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;1154.577,1175.293;Float;True;PixelNormal;3;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;175;-1446.819,-1348.9;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;139;1449.187,653.8961;Inherit;False;8;BlendComponents;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;73;-574.5253,-793.0415;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;181;2026.879,535.2369;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldToObjectMatrix;56;-1160.535,-162.0035;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CommentaryNode;57;-1093.432,-622.5464;Inherit;False;317.8;243.84;Coverage in World mode;1;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1021.977,266.1664;Float;False;Property;_CoverageFalloff;Coverage Falloff;9;0;Create;True;0;0;False;0;False;0.5;0.14;0.01;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;70;-574.5253,-521.0415;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;69;-652.7336,-604.1461;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1032.933,143.9565;Float;False;Property;_CoverageAmount;Coverage Amount;8;0;Create;True;0;0;False;0;False;0;-0.73;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;174;-1487.192,-1624.75;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;182;2039.649,792.3291;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;180;2046.507,170.6611;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;52;-1710.525,-1289.042;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;54;-1161.505,-59.18054;Inherit;False;55;PixelNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;176;-1461.531,-1056.691;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;64;-1438.525,-857.0415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-1245.49,-1578.01;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;125;2252.621,524.3269;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;81;-1193.59,-1038.41;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-1319.271,-882.3088;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;2220.118,638.8015;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;18;-828.3728,578.5031;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;20;-638.5253,406.9585;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;122;1785.187,509.8961;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;165;2171.024,939.562;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;74;-1523.525,-1373.042;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;2244.877,241.8326;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-917.9349,-139.8135;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;83;-334.5253,-697.0415;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1278.996,-1456.308;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-1282.941,-1197.449;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;2210.679,359.3741;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;71;-1406.525,-825.0415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;67;-1710.525,-1145.042;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;84;-1238.738,-1321.242;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;119;1785.187,797.8954;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;123;2262.487,806.8573;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-1024.411,-515.4789;Inherit;False;55;PixelNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;31;-492.3721,690.5035;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;126;2057.187,461.8961;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-1076.545,-1313.532;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;77;-670.5253,-825.0415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;91;-174.5253,-697.0415;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;30;-300.3718,834.5037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;28;-553.3722,501.5028;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;124;2057.187,973.8954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;2397.42,832.4791;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;2405.075,256.2911;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;66;-588.4324,108.7535;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-1058.875,-957.3918;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;76;-670.5253,-1097.042;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;80;-670.5253,-1369.042;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-1069.6,-1601.391;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;72;-700.5253,-326.0415;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;2388.514,535.7185;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;89;-923.225,-1557.942;Inherit;True;Property;_TriplanarAlbedo;Triplanar Albedo;0;0;Create;True;0;0;False;0;False;-1;None;d0c46703cf1657e489200a11a5d5c760;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;129;2553.185,829.8954;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;False;Instance;127;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;128;2089.187,429.8961;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;79;-319.533,288.1545;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-332.3719,674.5034;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-95.69275,-502.2892;Inherit;False;147;TextureScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;36;-284.3719,930.5039;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;88;-638.5253,-857.0415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;50.10931,-684.2107;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;132;1785.187,653.8961;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;127;2552.756,253.8954;Inherit;True;Property;_Metallic;Metallic;2;0;Create;True;0;0;False;0;False;-1;None;32b32591980b5bd4aa89d5026a213a96;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-446.5253,-314.0415;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;87;-925.5227,-1024.543;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;89;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;86;-638.5253,-1401.042;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;130;2089.187,1005.895;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;93;-928.3074,-1302.48;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;89;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;131;2553.185,525.8961;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;False;Instance;127;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;92;-638.5253,-1129.042;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;40;-252.3718,962.5038;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-558.5253,-1065.042;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;2953.185,381.8961;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;2953.185,957.8954;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;85;-228.733,192.9545;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-558.5253,-1305.042;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;39;-186.3718,840.5037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;197.7032,-642.3722;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;90;-302.5253,-306.0415;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;2953.185,653.8961;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-558.5253,-1577.042;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;97;-126.5253,-313.0415;Inherit;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;3193.186,493.8961;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;-318.5253,-1465.042;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;101;-302.5253,-1113.042;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;137;3177.185,797.8954;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;99;343.4747,-714.0415;Inherit;True;Property;_TopAlbedo;Top Albedo;3;0;Create;True;0;0;False;0;False;-1;None;7f08ee6a4e2a0f4408664880aecff782;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;43;30.6281,828.5037;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;41;-409.2518,1250.503;Inherit;True;Property;_TopNormal;Top Normal;4;0;Create;True;0;0;False;0;False;-1;None;43a2174fbe4ea0745b72df6e95a4e3bb;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;140;3433.186,685.8964;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;136;3356.306,909.8954;Inherit;True;Property;_TopMetallic;Top Metallic;5;0;Create;True;0;0;True;0;False;-1;None;587f7b9aecf33ee4b8f2c5ca769cd35a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;104;-62.52527,-1209.042;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;106;532.7657,-1007.746;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;46;364.9747,1000.391;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;100;248.3748,-314.3415;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;141;3961.186,685.8964;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;184;-1882.983,-1395.889;Float;False;normalBlendStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;1534.879,-954.568;Inherit;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;4256.677,671.6001;Float;True;PixelMetallic;3;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;107;732.4747,-1211.042;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;575.1459,972.053;Float;True;CalculatedNormal;2;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-2210.22,-1403.137;Inherit;False;Property;_NormalBlendStrength;Normal Blend Strength;11;0;Create;True;0;0;False;0;False;0;0.69;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;114;2136.14,-1141.92;Float;False;True;-1;7;ASEMaterialInspector;0;0;Standard;treytriplanar;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;5;0;3;0
WireConnection;6;0;5;0
WireConnection;6;1;4;0
WireConnection;7;0;5;0
WireConnection;7;1;6;0
WireConnection;8;0;7;0
WireConnection;147;0;148;0
WireConnection;14;0;9;0
WireConnection;22;0;178;1
WireConnection;22;1;178;3
WireConnection;11;0;9;0
WireConnection;23;0;177;2
WireConnection;23;1;177;3
WireConnection;21;0;179;1
WireConnection;21;1;179;2
WireConnection;17;0;14;2
WireConnection;157;0;22;0
WireConnection;157;1;156;0
WireConnection;159;0;21;0
WireConnection;159;1;158;0
WireConnection;155;0;23;0
WireConnection;155;1;154;0
WireConnection;19;0;11;0
WireConnection;27;1;157;0
WireConnection;25;0;9;0
WireConnection;24;1;155;0
WireConnection;29;1;159;0
WireConnection;32;0;17;0
WireConnection;26;0;19;0
WireConnection;37;0;24;0
WireConnection;37;1;26;0
WireConnection;34;0;29;0
WireConnection;34;1;32;0
WireConnection;35;0;27;0
WireConnection;35;1;25;1
WireConnection;38;0;37;0
WireConnection;38;1;35;0
WireConnection;42;0;34;0
WireConnection;45;0;38;0
WireConnection;45;1;42;0
WireConnection;49;0;45;0
WireConnection;51;0;50;0
WireConnection;53;0;8;0
WireConnection;62;0;51;0
WireConnection;55;0;49;0
WireConnection;69;0;62;0
WireConnection;52;0;8;0
WireConnection;64;0;53;2
WireConnection;82;0;174;2
WireConnection;82;1;174;3
WireConnection;125;0;181;1
WireConnection;125;1;181;3
WireConnection;81;0;176;1
WireConnection;81;1;176;2
WireConnection;18;0;12;0
WireConnection;20;0;10;0
WireConnection;122;0;139;0
WireConnection;74;0;52;0
WireConnection;162;0;180;2
WireConnection;162;1;180;3
WireConnection;59;0;56;0
WireConnection;59;1;54;0
WireConnection;83;0;73;0
WireConnection;83;1;70;0
WireConnection;83;2;69;0
WireConnection;71;0;64;0
WireConnection;67;0;8;0
WireConnection;84;0;175;1
WireConnection;84;1;175;3
WireConnection;119;0;139;0
WireConnection;123;0;182;1
WireConnection;123;1;182;2
WireConnection;31;0;20;0
WireConnection;126;0;122;0
WireConnection;151;0;84;0
WireConnection;151;1;150;0
WireConnection;77;0;71;0
WireConnection;91;0;83;0
WireConnection;30;0;18;0
WireConnection;124;0;119;2
WireConnection;166;0;123;0
WireConnection;166;1;165;0
WireConnection;161;0;162;0
WireConnection;161;1;160;0
WireConnection;66;0;10;0
WireConnection;153;0;81;0
WireConnection;153;1;152;0
WireConnection;76;0;67;1
WireConnection;80;0;74;0
WireConnection;143;0;82;0
WireConnection;143;1;149;0
WireConnection;72;0;63;0
WireConnection;72;1;59;0
WireConnection;72;2;51;0
WireConnection;164;0;125;0
WireConnection;164;1;163;0
WireConnection;89;1;143;0
WireConnection;129;1;166;0
WireConnection;128;0;126;0
WireConnection;79;0;12;0
WireConnection;33;0;28;2
WireConnection;33;1;31;0
WireConnection;36;0;30;0
WireConnection;88;0;77;0
WireConnection;95;0;91;0
WireConnection;95;1;91;2
WireConnection;132;0;139;0
WireConnection;127;1;161;0
WireConnection;78;0;72;0
WireConnection;78;1;66;0
WireConnection;87;1;153;0
WireConnection;86;0;80;0
WireConnection;130;0;124;0
WireConnection;93;1;151;0
WireConnection;131;1;164;0
WireConnection;92;0;76;0
WireConnection;40;0;36;0
WireConnection;96;0;87;0
WireConnection;96;1;88;0
WireConnection;133;0;127;0
WireConnection;133;1;128;0
WireConnection;135;0;129;0
WireConnection;135;1;130;0
WireConnection;85;0;79;0
WireConnection;94;0;93;0
WireConnection;94;1;92;0
WireConnection;39;0;33;0
WireConnection;168;0;95;0
WireConnection;168;1;167;0
WireConnection;90;0;78;0
WireConnection;134;0;131;0
WireConnection;134;1;132;1
WireConnection;98;0;89;0
WireConnection;98;1;86;0
WireConnection;97;0;90;0
WireConnection;97;1;85;0
WireConnection;138;0;133;0
WireConnection;138;1;134;0
WireConnection;102;0;98;0
WireConnection;102;1;94;0
WireConnection;101;0;96;0
WireConnection;137;0;135;0
WireConnection;99;1;168;0
WireConnection;43;0;39;0
WireConnection;43;1;40;0
WireConnection;41;1;168;0
WireConnection;140;0;138;0
WireConnection;140;1;137;0
WireConnection;136;1;168;0
WireConnection;104;0;102;0
WireConnection;104;1;101;0
WireConnection;106;0;99;0
WireConnection;46;0;45;0
WireConnection;46;1;41;0
WireConnection;46;2;43;0
WireConnection;100;0;97;0
WireConnection;141;0;140;0
WireConnection;141;1;136;0
WireConnection;141;2;43;0
WireConnection;184;0;183;0
WireConnection;172;0;141;0
WireConnection;107;0;104;0
WireConnection;107;1;106;0
WireConnection;107;2;100;1
WireConnection;47;0;46;0
WireConnection;114;0;107;0
WireConnection;114;1;47;0
WireConnection;114;3;141;0
WireConnection;114;4;173;0
ASEEND*/
//CHKSM=2F8B6652EADFB143F53A07C91370B3B8FABEF302