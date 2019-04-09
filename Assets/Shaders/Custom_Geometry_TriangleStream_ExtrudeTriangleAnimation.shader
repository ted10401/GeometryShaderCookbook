Shader "Custom/Geometry/TriangleStream/ExtrudeTriangleAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BottomColor ("Bottom Color", Color) = (0, 0, 0, 1)
        _TopColor ("Top Color", Color) = (1, 1, 1, 1)
        _ExtrudeMaxValue ("Extrude Max Value", Range(0, 1)) = 1
		_ExtrudeRandomValue ("Extrude Random Value", Range(0, 1)) = 1
		_ExtrudeSpeed ("Extrude Speed", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Cull Off

            CGPROGRAM
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

			struct v2g
			{
				float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
			};

            struct g2f
            {
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
				float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _BottomColor;
            float4 _TopColor;
            float _ExtrudeMaxValue;
			float _ExtrudeRandomValue;
			float _ExtrudeSpeed;

            v2g vert (a2v v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			float3 ConstructNormal(float3 v1, float3 v2, float3 v3)
            {
                return normalize(cross(v2 - v1, v3 - v1));
            }

			[maxvertexcount(21)]
			void geom(triangle v2g input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> outStream)
			{
				float extrudeAmount = cos(_Time.y * 2 * UNITY_PI * _ExtrudeSpeed) * 0.5 + 0.5;
				extrudeAmount *= _ExtrudeMaxValue;
				extrudeAmount += (sin(pid * 832.37843 + _Time.y * 2 * UNITY_PI * _ExtrudeSpeed) * 0.5 + 0.5) * _ExtrudeRandomValue;

				float3 normal = ConstructNormal(input[0].vertex, input[1].vertex, input[2].vertex);
				normal = normal * extrudeAmount;

				g2f o;

				for(int i = 0; i < 3; i++)
				{
					int index = (i + 1) % 3;

					o.vertex = input[i].vertex;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					o.color = _BottomColor;
					outStream.Append(o);

					o.vertex = input[i].vertex;
					o.vertex.xyz += normal;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					o.color = _TopColor;
					outStream.Append(o);

					o.vertex = input[index].vertex;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[index].uv;
					o.color = _BottomColor;
					outStream.Append(o);

					outStream.RestartStrip();

					o.vertex = input[i].vertex;
					o.vertex.xyz += normal;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					o.color = _TopColor;
					outStream.Append(o);

					o.vertex = input[index].vertex;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[index].uv;
					o.color = _BottomColor;
					outStream.Append(o);

					o.vertex = input[index].vertex;
					o.vertex.xyz += normal;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[index].uv;
					o.color = _TopColor;
					outStream.Append(o);

					outStream.RestartStrip();
				}

				for(int i = 0; i < 3; i++)
                {
                    o.vertex = input[i].vertex;
					o.vertex.xyz += normal;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					o.color = _TopColor;
					outStream.Append(o);
                }

				outStream.RestartStrip();
			}

            fixed4 frag (g2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                return col;
            }
            ENDCG
        }
    }
}
