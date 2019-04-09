Shader "Custom/Geometry/TriangleStream/ExtrudeVertex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)
		_ExtrudeValue ("Extrude Value", Float) = 0
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
				float3 normal : NORMAL;
            };

			struct v2g
			{
				float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

            struct g2f
            {
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;
			float _ExtrudeValue;

            v2g vert (a2v v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
                return o;
            }

			[maxvertexcount(3)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
			{
				g2f o;

				for(int i = 0; i < 3; i++)
				{
					o.vertex = input[i].vertex;
					o.vertex.xyz += input[i].normal * _ExtrudeValue;
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = input[i].uv;
					outStream.Append(o);
				}
				
				outStream.RestartStrip();
			}

            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
