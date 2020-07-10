Shader "CGLecture/VertexTransforms"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} 
    }
	SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
            {
                float4 vertex : POSITION; 
                float2 uv : TEXCOORD0;
            };

			struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			sampler2D _MainTex; 

			//World Transform Matrix
			float4x4 TranslationMatrix4x4(float x, float y, float z)
			{
				float4x4 T = { 1, 0, 0, x,
							   0, 1, 0, y,
							   0, 0, 1, z,
							   0, 0, 0, 1 };
				return T;
			}

			//View Transform Matrix
			float4x4 ViewTransformMatrix4x4(float3 eye, float3 at, float3 up)
			{
				float3 n = normalize(eye - at);
				float3 u = normalize(cross(up, n));
				float3 v = cross(n, u);

				float4x4 V = { u.x, u.y, u.z, -dot(u,eye),
							   v.x, v.y, v.z, -dot(v,eye),
							   n.x, n.y, n.z, -dot(n,eye),
								 0,   0,   0,           1 };

				return V;
			}

			//Projection Transform Matrix
			float4x4 ProjectionTransformMatrix4x4(float fovy, float aspect, float n, float f)
			{
				float4x4 P = { 1 / (tan(fovy / 2)* aspect),	0,	0,	0,
							   0, 1/tan(fovy / 2), 0, 0,
							   0, 0, -(f+n)/(f-n), 2*n*f/(f-n),
							   0, 0, -1, 0 };
				return P;
			}



			v2f vert (appdata v)
            {
                v2f o; 
                //o.vertex = UnityObjectToClipPos(v.vertex); 
				//위 코드 대신, 배운 내용을 바탕으로 Model, View, Projection Transformation 직접 해 보자.

				float4x4 T = TranslationMatrix4x4(0, 0, 8); //물체가 (0,0,10) 위치에 있음
				float4x4 V = ViewTransformMatrix4x4(float3(0, 0, 10), float3(0, 0, 0), float3(0, 1, 0)); //카메라가(0,0,0) 위치에서, (0,0,10)을 바라보고 있음. 정수리는 (0,1,0)
				float4x4 P = ProjectionTransformMatrix4x4(3.14 / 4, 1, -0.1, -1000);
				
				float4x4 VM = mul(V, T);
				float4x4 PVM = mul(P, VM);
				o.vertex = mul(PVM, v.vertex);

                o.uv = v.uv; 
                return o;
            }

			//실제 Fragment Shader 프로그램 코드 (입력 : v2f, 출력 : fixed4 (RGBA))
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv); //텍스처링을 통해 픽셀 색상을 계산
                return col;
            }
            ENDCG
        }
    }
}
