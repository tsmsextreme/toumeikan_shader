Shader "Custom/edge"
{

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Order ("Order", Float) = 4
        _Distance ("Distance", Float) = 1.5 
        _StencilReference("Stencil Reference", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComparison("Stencil Comparison", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOperation("Stencil Operation", Int) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        //Blend DstColor SrcColor,DstAlpha OneMinusSrcAlpha
        //ColorMask RGB
        //Cull Off 
        //Lighting Off 
        //ZWrite Off
        LOD 100
        Stencil
        {
            Ref[_StencilReference]
            Comp[_StencilComparison]
            Pass[_StencilOperation]
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL; 
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1; 
                float3 worldPos : POSITION1;
                float3 viewWS : TEXCOORD2;
            };

            sampler2D _MainTex;
            int _Order;
            float _Distance;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex = v.vertex;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                o.viewWS = WorldSpaceViewDir(v.vertex);
                return o;
            }
            float kyori(float3 vec){
                return abs(vec.x)+abs(vec.y)+abs(vec.z);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                
                float3 eye = _WorldSpaceCameraPos.xyz - i.worldPos;
                float da = max(0, dot(normalize(i.viewWS), i.normal));
                //if(da > 0.9) da = 1/zettaiti(eye);
                da = min(max(1-da, pow(_Distance-kyori(eye),5)),1);
                //float da = max(0, dot(normalize(i.viewWS), i.normal))/zettaiti(eye);
                //float d = dot(eyeDir, cross(eyeDir, i.normal));
                //float t = pow(d,2);
                //fixed4 col = tex2D(_MainTex, i.uv);
                //return fixed4(cross(eyeDir, i.normal),0);
                //return pow(da,5);
                fixed4 col = tex2D(_MainTex, i.uv);
                return fixed4(col.xyz ,pow(da,_Order));
                //return kyori(eye)/10-0.1;
            }


            
            ENDCG
        }
    }
}
