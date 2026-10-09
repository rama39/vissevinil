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
    float energia = 0.9 + 2.6 * agitacao;

    // Ondas horizontais, como a superfície se mexendo (comprimento e altura maiores)
    float onda1 = sin(posicao.y * 0.22 - tempo * 2.0 + sin(posicao.x * 0.015 + tempo) * 1.5);
    float onda2 = sin(posicao.y * 0.08 + posicao.x * 0.012 - tempo * 1.4);
    float dx = (onda1 * 2.4 + onda2 * 3.2) * forca * energia;
    float dy = sin(posicao.x * 0.03 - tempo * 1.6) * 1.4 * forca * energia;

    // Onda circular a partir do toque, abrindo e perdendo força
    const float duracao = 2.2;
    if (idade >= 0.0 && idade < duracao) {
        float2 delta = posicao - origem;
        float distancia = length(delta);
        float anel = distancia - idade * 140.0;
        float envelope = exp(-(anel * anel) / 500.0) * (1.0 - idade / duracao);
        float2 direcao = distancia > 0.001 ? delta / distancia : float2(0.0);
        float amplitude = sin(anel * 0.25) * 10.0 * envelope;
        dx += direcao.x * amplitude;
        dy += direcao.y * amplitude;
    }

    return posicao + float2(dx, dy);
}
