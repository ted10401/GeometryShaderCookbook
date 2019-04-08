Shader "Custom/Geometry/TriangleStream/ExtrudePyramid"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BottomColor ("Bottom Color", Color) = (0, 0, 0, 1)
        _TopColor ("Top Color", Color) = (1, 1, 1, 1)
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
            }

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
            float _ExtrudeValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            float3 ConstructNormal(float3 v1, float3 v2, float3 v3)
            {
                return normalize(cross(v2 - v1, v3 - v1));
            }
            
            [maxvertexcount(9)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {
                float edge0 = distance(input[0].vertex, input[1].vertex);
                float edge1 = distance(input[1].vertex, input[2].vertex);
                float edge2 = distance(input[0].vertex, input[2].vertex);
                
                float longestEdge = edge0;
                float4 topVertex = (input[0].vertex + input[1].vertex) / 2;
                float2 topUV = (input[0].uv + input[1].uv) / 2;
                
                if(edge1 > longestEdge)
                {
                    longestEdge = edge1;
                    topVertex = (input[1].vertex + input[2].vertex) / 2;
                    topUV = (input[1].uv + input[2].uv) / 2;
                }
                
                if(edge2 > longestEdge)
                {
                    longestEdge = edge2;
                    topVertex = (input[0].vertex + input[1].vertex) / 2;
                    topUV = (input[0].uv + input[1].uv) / 2;
                }
                
                float3 normal = ConstructNormal(input[0].vertex, input[1].vertex, input[2].vertex);
                topVertex.xyz += normal * _ExtrudeValue;
                
                g2f o;
                for(int i = 0; i < 3; i++)
                {
                    o.vertex = input[i].vertex;
                    o.vertex = UnityObjectToClipPos(o.vertex);
                    o.uv = input[i].uv;
                    o.color = _BottomColor;
                    outStream.Append(o);
                    
                    o.vertex = UnityObjectToClipPos(topVertex);
                    o.uv = topUV;
                    o.color = _TopColor;
                    outStream.Append(o);
                    
                    o.vertex = input[(i + 1) % 3].vertex;
                    o.vertex = UnityObjectToClipPos(o.vertex);
                    o.uv = input[(i + 1) % 3].uv;
                    o.color = _BottomColor;
                    outStream.Append(o);
                    
                    outStream.RestartStrip();
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
