# VisseVinil

**VisseVinil** é um aplicativo para iPhone voltado para colecionadores de vinil de Recife. O app facilita a organização da coleção e indica locais para garimpar discos.

Com o VisseVinil, a sua interação com os discos é registrada como um diário: juntos, você e o disco constroem uma história.

## Funcionalidades

### 📦 Organize seus discos
Crie caixas digitais para organizar os discos do jeito que eles estão na sua casa. É um mapa digital dos seus discos: achar um disco nunca foi tão fácil!

- Caixas com nome e cor, do jeito que estão na sua estante
- Ordenação por título, artista, data de lançamento, data de inclusão ou ordem manual
- Modo **Caixa**, para folhear os discos como num sebo
- Registro de quando você tira um disco da caixa para ouvir

### 📖 Um diário com cada disco
Cada interação com um disco fica registrada: quando ele entrou na coleção, quando foi ouvido, os comentários que você fez. Juntos, você e o disco constroem uma história.

### 🗺️ Conheça novas lojas
Nosso mapa tem uma curadoria de lojas de Recife para você descobrir novos discos.

- Lojas e locais para garimpar, com detalhes, contato e rota pelo app Mapas
- Locais favoritos e fixados, com busca
- Avaliações e comentários pessoais sobre cada lugar

### 👤 Customize seu perfil
Crie uma visualização de quem você é como colecionador. Escolha seus discos favoritos e mostre há quanto tempo você coleciona!

- Foto de perfil com borda personalizável (cores sugeridas, degradês ou qualquer cor)
- Carrossel dos seus 4 discos favoritos, com reflexo em água que reage ao toque
- Seus discos e os discos que você curtiu na busca

### 🔎 Busque discos
Pesquise lançamentos no catálogo do [Discogs](https://www.discogs.com), veja as versões de cada disco, curta e adicione à sua coleção.

## Requisitos

- iPhone com **iOS 26.5** ou mais recente
- **Xcode 26** ou mais recente
- **Metal Toolchain**: o reflexo em água do Perfil é um shader Metal. Na primeira compilação, o Xcode oferece o download (botão **Get**). Também dá para baixar pelo Terminal:

  ```sh
  xcodebuild -downloadComponent MetalToolchain
  ```

## Como rodar

1. Clone o repositório:

   ```sh
   git clone https://github.com/rama39/VisseVinil.git
   ```

2. Abra `VisseVinil.xcodeproj` no Xcode.
3. Espere o Xcode baixar os pacotes Swift (ClusterMap). Se não baixar sozinho, use **File → Packages → Resolve Package Versions**.
4. Em **Signing & Capabilities**, escolha o seu time de desenvolvimento.
5. Escolha um iPhone ou simulador e rode (⌘R).

## Tecnologias

| Área | Tecnologia |
|---|---|
| Interface | SwiftUI (Liquid Glass, iOS 26) |
| Dados | SwiftData (tudo salvo no aparelho) |
| Mapa | MapKit, Core Location, [ClusterMap](https://github.com/vospennikov/ClusterMap) |
| Efeitos | Metal (shader de água no Perfil) |
| Catálogo de discos | [API do Discogs](https://www.discogs.com/developers) |

## Estrutura do projeto

```
VisseVinil/
├── App/            # Ponto de entrada, abas e esquema do SwiftData
├── Features/
│   ├── Onboarding/ # Primeira abertura: privacidade, perfil e foto
│   ├── Colecao/    # Caixas, discos, ordenação e diário
│   ├── Buscar/     # Busca no Discogs e discos curtidos
│   ├── Mapa/       # Lojas, mapa, detalhes, avaliações e rotas
│   └── Perfil/     # Perfil, favoritos e edição
└── Resources/      # Ícone do app e Assets (cores da paleta e imagens)
docs/               # Site de suporte e Política de Privacidade
```

Cada funcionalidade é organizada em `Models`, `Views`, `Services` e `Utilities`.

## Privacidade

O VisseVinil não tem servidores próprios: o perfil, a foto e a coleção ficam salvos **somente no aparelho**. A localização é usada apenas para mostrar lojas próximas e não é armazenada. As buscas de discos são enviadas ao Discogs.

Leia a [Política de Privacidade](https://rama39.github.io/vissevinil/Support/Politica_de_Privacidade_VisseVinil.pdf) completa.

## Suporte e contato

- Site de suporte: [rama39.github.io/vissevinil](https://rama39.github.io/vissevinil/)
- E-mail: [vissevinil@gmail.com](mailto:vissevinil@gmail.com)
- Instagram: [@vissevinil](https://instagram.com/vissevinil)

## Equipe

- **Gabriel Alves**: graduando em Engenharia da Programação no CIn-UFPE
- **Rian Antony**: graduando em Engenharia da Programação no CIn-UFPE
- **Pedro Augusto**: graduando em Psicologia na UFPE
- **Maria Eduarda Marrocos**: graduação em Design no CAC-UFPE

## Discogs

O VisseVinil não é afiliado, patrocinado ou endossado pelo Discogs.

Data provided by [Discogs](https://www.discogs.com).
