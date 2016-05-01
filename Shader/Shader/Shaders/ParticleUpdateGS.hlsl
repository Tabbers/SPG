
SamplerState samLinear : register(s0);
Texture1D randomTex : register(t0);

cbuffer MatrixBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;
}

//Once per app run constant buffer
cbuffer DataBuffer : register(b1)
{
    float4 data;
}

struct Particle
{
    float4  InitialPos : POSITION;
    float4  InitialVel : VELOCITY;
    float2  Size       : SIZE;
    float   Age        : AGE;
    unsigned int Type  : TYPE;
};

struct Type
{
    unsigned int EMITTER;
    unsigned int FLYING;
};

float3 RandUnitVec3(float offset)
{
    float u = (data.x + offset);
    float3 v = randomTex.SampleLevel(samLinear, u, 0).xyz;
    return normalize(v);
}

[maxvertexcount(21)]
void main(point Particle input[1], inout PointStream<Particle> output)
{
	output.Append(input[0]);
    Type t;
    t.EMITTER = 0;
    t.FLYING = 1;
	if(input[0].Type == t.EMITTER)
    {
        //Put the Emitter back in the StreamOutput
        Particle emitter;

        emitter.InitialPos = input[0].InitialPos;
        emitter.Age = input[0].Age + data.x;
        emitter.InitialVel = input[0].InitialVel;
        emitter.Size = input[0].Size;
        emitter.Type = input[0].Type;

        output.Append(emitter);

        if(input[0].Age < data.w)
        {
            for (int i = 0; i < 20; ++i)
            {
            //Add a new Emitted Particle
                Particle newParticle;
                newParticle.InitialPos = input[0].InitialPos;
                newParticle.InitialVel = float4(0.0f, 2.0f, 0.0f,0.0f);
                newParticle.Size = float2(1.0f, 1.0f);
                newParticle.Age = 0;
                newParticle.Type = t.FLYING;
                output.Append(newParticle);
            }
        }
    }
    else if(input[0].Type == t.FLYING)
    {
        if (input[0].Age < data.w)
        {
            Particle newParticle;
            newParticle.InitialPos = input[0].InitialPos + (input[0].InitialVel * data.x +(input[0].InitialVel * (data.x* data.x))*0.5);
            newParticle.InitialVel = (input[0].InitialVel * (data.x * data.x)) * 0.5;
            newParticle.Size = input[0].Size;
            newParticle.Age = input[0].Age + data.x;
            newParticle.Type = input[0].Type;

            output.Append(newParticle);
        }
    }
}