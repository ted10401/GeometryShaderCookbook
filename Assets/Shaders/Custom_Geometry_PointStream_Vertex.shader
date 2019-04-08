Shader "Custom/Geometry/PointStream/Vertex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2g vert (a2v v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			[maxvertexcount(1)]
			void geom(triangle v2g input[3], inout PointStream<g2f> outStream)
			{
				float4 vertex = float4(0, 0, 0, 0);
				float2 uv = float2(0, 0);

				for(int i = 0; i < 3; i++)
				{
					vertex += input[i].vertex;
					uv += input[i].uv;
				}

				vertex /= 3;
				uv /= 3;

				g2f o;
				o.vertex = UnityObjectToClipPos(vertex);
				o.uv = uv;

				outStream.Append(o);
			}

            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
