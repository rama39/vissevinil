//
//  Agua.metal
//  VisseVinil
//
//  Distorção que faz o reflexo das capas parecer água (usado com .distortionEffect).
//  Recebe a posição de cada pixel e devolve de onde a imagem deve ser lida.
//

#include <metal_stdlib>
using namespace metal;

/// - tempo: segundos (anima as ondas)
/// - agitacao: 0 = água calma ... 1 = mexida (cresce ao arrastar o carrossel e vai acalmando)
/// - tamanho: largura e altura da área de água, em pontos
/// - origem: onde o dedo tocou na água (centro da onda circular)
/// - idade: segundos desde o toque (negativo = sem onda circular)
[[ stitchable ]] float2 agua(float2 posicao, float tempo, float agitacao, float2 tamanho,
                             float2 origem, float idade) {
    // 0 na linha d'água (encostado nas capas) até 1 no fundo: longe da linha, ondula mais
    float profundidade = clamp(posicao.y / max(tamanho.y, 1.0), 0.0, 1.0);
    float forca = mix(0.2, 1.0, profundidade);
    float energia = 0.6 + 3.0 * agitacao;

    // Ondas horizontais suaves, como a superfície se mexendo
    float onda1 = sin(posicao.y * 0.35 - tempo * 2.4 + sin(posicao.x * 0.02 + tempo) * 1.5);
    float onda2 = sin(posicao.y * 0.12 + posicao.x * 0.015 - tempo * 1.6);
    float dx = (onda1 * 1.2 + onda2 * 1.8) * forca * energia;
    float dy = sin(posicao.x * 0.04 - tempo * 1.9) * 0.6 * forca * energia;

    // Onda circular a partir do toque, abrindo e perdendo força
    const float duracao = 2.2;
    if (idade >= 0.0 && idade < duracao) {
        float2 delta = posicao - origem;
        float distancia = length(delta);
        float anel = distancia - idade * 140.0;
        float envelope = exp(-(anel * anel) / 300.0) * (1.0 - idade / duracao);
        float2 direcao = distancia > 0.001 ? delta / distancia : float2(0.0);
        float amplitude = sin(anel * 0.35) * 7.0 * envelope;
        dx += direcao.x * amplitude;
        dy += direcao.y * amplitude;
    }

    return posicao + float2(dx, dy);
}
