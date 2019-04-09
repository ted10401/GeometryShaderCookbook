Shader "Custom/Geometry/TriangleStream/TriangleAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BottomColor ("Bottom Color", Color) = (1, 1, 1, 1)
        _TopColor ("Top Color", Color) = (0, 0, 0, 1)
        _Threshold ("Threshold", Float) = 0
		_V0 ("V0", Float) = 0
		_A ("A", Float) = 0
		_SizeVelocity ("Size Velocity", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
            float _Threshold;
			float _V0;
			float _A;
			float _SizeVelocity;

            v2g vert (a2v v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {   
                float4 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;

				g2f o;
				for(int i = 0; i < 3; i++)
				{
					if(center.y >= _Threshold)
					{
						float t = center.y - _Threshold;
						float v = _V0 * t + 0.5 * _A * t * t;
						float4 dir = input[i].vertex - center;

						o.vertex = center;
						if(t * _SizeVelocity <= 1)
						{
							o.vertex += dir;
						}
						else
						{
							o.vertex += dir / (t * _SizeVelocity);
						}
						o.vertex.y += v;
						o.vertex = UnityObjectToClipPos(o.vertex);
						o.uv = input[i].uv;
						o.color = lerp(_BottomColor, _TopColor, t * _SizeVelocity);
						outStream.Append(o);
					}
					else
					{
						o.vertex = input[i].vertex;
						o.vertex = UnityObjectToClipPos(o.vertex);
						o.uv = input[i].uv;
						o.color = _BottomColor;
						outStream.Append(o);
					}
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
