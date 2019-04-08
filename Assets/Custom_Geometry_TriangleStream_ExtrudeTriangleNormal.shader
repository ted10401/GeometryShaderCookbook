Shader "Custom/Geometry/TriangleStream/ExtrudeTriangleNormal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ExtrudeValue ("Extrude Value", Float) = 0
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
			float _ExtrudeValue;

            v2g vert (a2v v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			[maxvertexcount(21)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
			{
				float3 dir1 = input[1].vertex - input[0].vertex;
				float3 dir2 = input[2].vertex - input[0].vertex;
				float3 normal = normalize(cross(dir1, dir2));

				g2f o;

				for(int i = 0; i < 3; i++)
				{
					o.vertex = input[i].vertex;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					o.color = float4(0, 0, 0, 1);
					outStream.Append(o);

					o.vertex = input[i].vertex;
					o.vertex.xyz += normal * _ExtrudeValue;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					o.color = float4(1, 1, 1, 1);
					outStream.Append(o);

					o.vertex = input[(i + 1) % 3].vertex;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[(i + 1) % 3].uv;
					o.color = float4(0, 0, 0, 1);
					outStream.Append(o);

					outStream.RestartStrip();

					o.vertex = input[i].vertex;
					o.vertex.xyz += normal * _ExtrudeValue;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					o.color = float4(1, 1, 1, 1);
					outStream.Append(o);

					o.vertex = input[(i + 1) % 3].vertex;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[(i + 1) % 3].uv;
					o.color = float4(0, 0, 0, 1);
					outStream.Append(o);

					o.vertex = input[(i + 1) % 3].vertex;
					o.vertex.xyz += normal * _ExtrudeValue;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[(i + 1) % 3].uv;
					o.color = float4(1, 1, 1, 1);
					outStream.Append(o);

					outStream.RestartStrip();
				}

				for(int i = 0; i < 3; i++)
                {
                    o.vertex = input[i].vertex;
					o.vertex.xyz += normal * _ExtrudeValue;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					o.color = float4(1, 1, 1, 1);
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
