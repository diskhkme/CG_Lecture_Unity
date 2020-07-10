Shader "CGLecture/BasicStructure"
{
	//기본적인 Shader 프로그램
    Properties
    {
		//(응용 프로그램에서 입력할 데이터 설정 가능)
        _MainTex ("Texture", 2D) = "white" {} 
    }
	SubShader
    {
        Pass
        {
			//CG Shader 코드 파트
            CGPROGRAM
            #pragma vertex vert //vertex shader의 함수 이름이 "vert" 라는 것을 알려줌
            #pragma fragment frag //fragment shader의 함수 이름이 "frag" 라는 것을 알려줌

			//Unity 자체에서 제공하는 유틸리티 함수를 사용하기 위한 헤더 파일
            #include "UnityCG.cginc"

			//Vertex shader로 입력할 데이터 구조체 정의
			//Unity에서 내부적으로 각 모델의 vertex 정보, uv 정보 등을 appdata 구조체에 담아 전달하게 되어있음
            struct appdata
            {
                float4 vertex : POSITION; //뒤쪽의 ": POSITION"이, 어떤 종류의 데이터가 어떤 변수에 담길지를 설정해줌
                float2 uv : TEXCOORD0;
            };

			//Fragment shader로 입력할 데이터(=vertex shader에서 출력해야 하는 데이터) 구조체 정의
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			sampler2D _MainTex; //최상단, 응용 프로그램에서 설정한 데이터를 셰이더 프로그램에서 사용하기 위해서는 변수 설정 필요함


			//실제 Vertex Shader 프로그램 코드 (입력 : appdata, 출력 : v2f)
            v2f vert (appdata v)
            {
                v2f o; //출력할 빈 v2f 객체 생성
                o.vertex = UnityObjectToClipPos(v.vertex); //Model, View, Projection Transformation 수행한 뒤, vertex에 저장
                o.uv = v.uv; //uv 좌표는 그대로 전달
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
