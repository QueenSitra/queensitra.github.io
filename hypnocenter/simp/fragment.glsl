precision highp float;
varying vec2 vTextureCoord;
varying vec3 vLighting;
uniform float time;
uniform sampler2D uSampler;

#define max_blur_steps 12
#define max_blur_stepsf 12.0
#define tau 6.283185307179586

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

     float d = q.x - min(q.w, q.y);
     float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float threshold(vec4 color, float t){
    vec3 hsv = rgb2hsv(color.rgb);
    return smoothstep(t,t+0.4,hsv.z);
}

float thresholdColor(vec4 color, float t,vec4 color2){
    float n = distance(color,color2);
    return smoothstep(t,t+0.4,0.5);
}

vec4 boxBlur(sampler2D tex, vec2 uv, float blur){
    vec4 pixel = vec4(0.,0.,0.,0.);

    float step_count = 0.0;
    float range = 0.0005;
    
    float x2 = -range * max_blur_stepsf * 0.5;
    float y2 = -range * max_blur_stepsf * 0.5;

    float i = 0.0;

    for(int x = 0; x < max_blur_steps; x++){
        vec2 position = vec2(
            sin(i)*step_count,
            cos(i)*step_count
        );
        pixel += texture2D(tex,uv+position) * (1.0-length(position));
        i += tau / max_blur_stepsf;
        step_count += 0.001;
    }

    return pixel * 0.1;
}

  vec4 glow(sampler2D tex, vec2 uv){
    vec4 pixel = clamp(boxBlur(tex,uv,0.1),vec4(0.),vec4(1.0));
    vec4 bw = mix(vec4(0.,0.,0.,1.0), vec4(1.0,1.0,1.0,1.0),threshold(pixel,0.5));
    return bw;
  }

  vec4 glowColor(sampler2D tex, vec2 uv,vec4 color){
    vec4 pixel = clamp(boxBlur(tex,uv,0.1),vec4(0.),vec4(1.0));
    vec4 bw = mix(vec4(0.,0.,0.,1.0), vec4(1.0,1.0,1.0,1.0),thresholdColor(pixel,0.5,color));
    return bw;
  }

  void main(void) {
    vec2 uv = vTextureCoord;
    vec2 uv2 = vTextureCoord - vec2(0.5,0.5);
    uv2.x *= 1.77777;
    vec4 texelColor = texture2D(uSampler, vTextureCoord);
    
    gl_FragColor = vec4(0.0,0.0,0.0,0.0);

    //spiral
    float dis = length(uv2);
    float spiral = step(fract(log(dis) * 1.0 + fract(atan(uv2.x,uv2.y) / 6.282 + time * 0.5) + time ),0.5);
    
    //heart
    uv2.y -= sqrt(abs(uv2.x)) *0.5;
    uv2.x *= .7; 
    uv2.y += 0.1;
    dis = length(uv2);
    gl_FragColor.rgb -= smoothstep(0.3,0.35,dis+sin(time*8.0) * 0.1) * 0.1;
    gl_FragColor.r += spiral * 0.05;
  }