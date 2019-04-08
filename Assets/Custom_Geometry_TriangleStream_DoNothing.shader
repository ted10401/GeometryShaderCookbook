Shader "Custom/Geometry/TriangleStream/DoNothing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)
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
			float4 _Color;

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
				g2f o;

				for(int i = 0; i < 3; i++)
				{
					o.vertex = UnityObjectToClipPos(input[i].vertex);
					o.uv = input[i].uv;
					outStream.Append(o);
				}
				
				outStream.RestartStrip();
			}

            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return _Color;
            }
            ENDCG
        }
    }
}
