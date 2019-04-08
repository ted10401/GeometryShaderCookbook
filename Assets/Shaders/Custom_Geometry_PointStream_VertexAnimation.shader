Shader "Custom/Geometry/PointStream/VertexAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Threshold ("Threshold", Float) = 0
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
            }

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            [maxvertexcount(1)]
            void geom(triangle v2g input[3], inout PointStream<g2f> outStream)
            {   
                g2f o;
                o.vertex = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                o.vertex = UnityObjectToClipPos(o.vertex);
                o.uv = (input[0].uv + input[1].uv + input[2].uv) / 3;
                
                if(o.vertex.y >= _Threshold)
                {
                    outStream.Append(o);
                }
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
