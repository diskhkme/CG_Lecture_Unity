Shader "CGLecture/VertexTransforms"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} 
		_Position ("Position", Vector) = (0,0,0,1)
    }
	SubShader
    {
        Pass
        {
			Cull Back

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
			float4 _Position;

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
				float3 u = -normalize(cross(up, n)); //좌표계가 달라 sign을 바꾸어 주어야 함
				float3 v = -cross(n, u); //마찬가지

				float4x4 V = { u.x, u.y, u.z, -dot(u,eye),
							   v.x, v.y, v.z, -dot(v,eye),
							   n.x, n.y, n.z, -dot(n,eye),
								 0,   0,   0,           1 };

				return V;
			}

			//Projection Transform Matrix
			float4x4 ProjectionTransformMatrix4x4(float fovy, float aspect, float n, float f)
			{
				//https://www.sysnet.pe.kr/2/0/11695
				float4x4 P = { 1 / (tan(fovy / 2)* aspect),	0,	0,	0,
							   0, -1/tan(fovy / 2), 0, 0,
							   0, 0, -(f)/(f-n), -n*f/(f-n),
							   0, 0, -1, 0 };
				return P;
			}

			float4x4 ProjectionTransformMatrix4x4Alt(float l, float r, float t, float b, float n, float f)
			{

				float4x4 P = { (2 * n) / (r - l) ,	0,	0,	0,
							   0, -(2*n)/(t-b), 0, 0,
							   0, 0, -f/(f-n), -(f*n)/(f-n),
							   0, 0, -1, 0 };

				return P;
			}



			v2f vert (appdata v)
            {
                v2f o; 
                //o.vertex = UnityObjectToClipPos(v.vertex); 
				//or
				/*float4 pos = mul(unity_ObjectToWorld, v.vertex);
				pos = mul(UNITY_MATRIX_V, pos);
				pos = mul(UNITY_MATRIX_P, pos);
				o.vertex = pos;*/

				//하나씩 대체해보기
				float4x4 T = TranslationMatrix4x4(_Position.x, _Position.y, _Position.z);
				//float4 pos = mul(unity_ObjectToWorld, v.vertex);
				float4 pos = mul(T, v.vertex);

				float4x4 V = ViewTransformMatrix4x4(float3(0, 0, -10), float3(0, 0, 0), float3(0, 1, 0));
				//pos = mul(UNITY_MATRIX_V, pos);
				pos = mul(V,pos);

				//float4x4 P = ProjectionTransformMatrix4x4(3.14 / 2, 1, 0.1, 20);
				float4x4 P = ProjectionTransformMatrix4x4Alt(-1, 1, 1, -1, 1, 20);
				//pos = mul(UNITY_MATRIX_P,pos);
				pos = mul(P, pos);
				
				o.vertex = pos;
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
