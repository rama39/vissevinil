//
//  PoliticaDePrivacidade.swift
//  VisseVinil
//

import Foundation

/// Texto da Política de Privacidade, mostrado no app em texto nativo (acompanha o tamanho
/// de letra, o modo escuro e o VoiceOver).
/// É a transcrição de docs/Support/Politica_de_Privacidade_VisseVinil.pdf (publicado no site
/// de suporte): ao atualizar o PDF, atualize este texto e a data também.
/// Os textos aceitam Markdown (**negrito** e [links](url)).
enum PoliticaDePrivacidade {
    enum Bloco: Hashable {
        case paragrafo(String)
        case subtitulo(String)
        case lista([String])
    }

    struct Secao: Identifiable, Hashable {
        let titulo: String
        let blocos: [Bloco]
        var id: String { titulo }
    }

    static let titulo = "Política de Privacidade"
    static let ultimaAtualizacao = "8 de outubro de 2026"

    static let introducao = "Esta Política de Privacidade explica quais informações o VisseVinil utiliza, como essas informações são utilizadas, quando determinadas informações podem ser enviadas a terceiros e quais opções estão disponíveis para o usuário em relação aos seus dados."

    static let secoes: [Secao] = [
        Secao(titulo: "1. Sobre o VisseVinil", blocos: [
            .paragrafo("O VisseVinil é um aplicativo voltado para pessoas que colecionam discos de vinil."),
            .paragrafo("O aplicativo permite organizar uma coleção de discos, pesquisar informações sobre lançamentos, descobrir lugares para garimpar discos e registrar experiências relacionadas à coleção."),
            .paragrafo("Para oferecer essas funcionalidades, o VisseVinil utiliza informações armazenadas no dispositivo do usuário, os Serviços de Localização da Apple, quando autorizados pelo usuário, e a API do Discogs."),
        ]),
        Secao(titulo: "2. Informações utilizadas pelo VisseVinil", blocos: [
            .subtitulo("2.1 Nome de usuário"),
            .paragrafo("O VisseVinil permite que o usuário escolha um nome para ser utilizado em seu perfil."),
            .paragrafo("O nome escolhido não precisa ser o nome real do usuário e pode ser qualquer nome ou identificação que o próprio usuário deseje utilizar no aplicativo."),
            .paragrafo("O nome de usuário é armazenado somente no dispositivo e não é enviado aos servidores do VisseVinil ou ao Discogs."),
            .paragrafo("O VisseVinil utiliza esse nome exclusivamente para exibição e personalização do perfil dentro do próprio aplicativo."),
            .paragrafo("O VisseVinil não utiliza o nome de usuário para publicidade, análise de comportamento, criação de perfis, venda de informações ou qualquer outra finalidade diferente daquela relacionada à experiência dentro do aplicativo."),
            .subtitulo("2.2 Foto de perfil"),
            .paragrafo("O usuário pode adicionar uma foto ao seu perfil."),
            .paragrafo("A foto de perfil é armazenada somente no dispositivo e não é enviada aos servidores do VisseVinil ou ao Discogs."),
            .paragrafo("A foto é utilizada exclusivamente para exibição e personalização do perfil dentro do aplicativo."),
            .paragrafo("O usuário pode alterar sua foto de perfil sempre que desejar."),
            .paragrafo("O VisseVinil não utiliza a foto de perfil para publicidade, análise de comportamento, criação de perfis, venda de informações ou qualquer outra finalidade diferente daquela relacionada à experiência dentro do aplicativo."),
        ]),
        Secao(titulo: "3. Localização", blocos: [
            .paragrafo("Com a autorização do usuário, o VisseVinil pode acessar a localização do dispositivo para oferecer funcionalidades relacionadas à localização, principalmente para auxiliar na descoberta de lugares para garimpar discos."),
            .paragrafo("A localização é utilizada somente para essa finalidade e não é armazenada pelo VisseVinil, nem em servidores próprios nem como um dado persistente no armazenamento local do aplicativo."),
            .paragrafo("O usuário pode negar ou retirar a autorização de acesso à localização a qualquer momento pelas configurações de privacidade do dispositivo."),
            .paragrafo("O VisseVinil continua funcionando mesmo quando o usuário não autoriza o acesso à localização. As demais funcionalidades do aplicativo, incluindo o mapa disponível no aplicativo, permanecem acessíveis sem essa autorização."),
        ]),
        Secao(titulo: "4. Pesquisa e conteúdo obtido por meio da API do Discogs", blocos: [
            .paragrafo("O VisseVinil utiliza a API do Discogs para pesquisar e apresentar informações relacionadas a discos de vinil."),
            .paragrafo("Quando o usuário realiza uma pesquisa, as informações necessárias para processar essa pesquisa podem ser enviadas ao Discogs por meio da API. Isso pode incluir:"),
            .lista([
                "o termo ou conteúdo pesquisado;",
                "o endereço IP do dispositivo;",
                "informações técnicas necessárias para processar a solicitação.",
            ]),
            .paragrafo("Essas informações são enviadas ao Discogs para que a pesquisa solicitada pelo usuário possa ser processada e apresentada no aplicativo."),
            .paragrafo("O VisseVinil não utiliza o conteúdo das pesquisas para finalidades próprias diferentes da prestação da funcionalidade de pesquisa."),
            .subtitulo("4.1 Imagens das capas dos discos"),
            .paragrafo("O VisseVinil também utiliza a API do Discogs para obter e exibir imagens das capas de lançamentos musicais apresentadas no aplicativo."),
            .paragrafo("As imagens e demais conteúdos obtidos por meio da API são utilizados para oferecer as funcionalidades de pesquisa, identificação e organização de discos disponíveis no VisseVinil."),
            .paragrafo("O uso desses conteúdos está sujeito aos Termos de Uso da API do Discogs e às políticas aplicáveis do Discogs. O Discogs classifica determinadas imagens de lançamentos como conteúdo de uso restrito (“Restricted Data”) e estabelece regras específicas para sua utilização."),
            .paragrafo("O VisseVinil não reivindica a propriedade das imagens ou dos demais conteúdos fornecidos pelo Discogs."),
            .paragrafo("Para informações sobre o tratamento de dados realizado pelo Discogs, o usuário pode consultar a própria Política de Privacidade do Discogs."),
        ]),
        Secao(titulo: "5. Compartilhamento de informações com o Discogs", blocos: [
            .paragrafo("O VisseVinil não envia ao Discogs o nome de usuário ou a foto de perfil armazenados localmente."),
            .paragrafo("A localização do usuário também não é enviada ao Discogs pelo VisseVinil."),
            .paragrafo("O compartilhamento com o Discogs ocorre quando o usuário utiliza a funcionalidade de pesquisa que depende da API do Discogs. Nessa situação, os dados necessários para processar a solicitação podem ser enviados ao Discogs, incluindo o conteúdo pesquisado, o endereço IP e informações técnicas relacionadas à solicitação."),
            .paragrafo("O Discogs informa em sua Política de Privacidade que pode processar informações como identificadores, endereço IP, histórico de pesquisas e informações técnicas do dispositivo para fornecer seus serviços. A política também informa que os dados pessoais são mantidos pelo período razoavelmente necessário para fornecer o serviço e cumprir obrigações legais."),
            .paragrafo("O Discogs também informa que adota medidas técnicas e organizacionais para proteger os dados pessoais, incluindo controles de acesso, criptografia, segurança de rede, proteção de armazenamento e medidas de gerenciamento de vulnerabilidades."),
            .paragrafo("O tratamento realizado pelo Discogs está sujeito à Política de Privacidade do próprio Discogs, incluindo suas regras de retenção, segurança, transferência e exercício de direitos relacionados aos dados pessoais."),
        ]),
        Secao(titulo: "6. Armazenamento dos dados no dispositivo", blocos: [
            .paragrafo("As informações relacionadas à utilização pessoal do VisseVinil, incluindo o nome de usuário, a foto de perfil e os dados da coleção mantidos pelo aplicativo, são armazenadas localmente no dispositivo do usuário."),
            .paragrafo("O VisseVinil não mantém uma cópia desses dados em servidores próprios."),
            .paragrafo("O usuário é responsável pelo armazenamento desses dados em seu dispositivo e pelas configurações de segurança e backup do próprio dispositivo."),
        ]),
        Secao(titulo: "7. Retenção e exclusão de dados", blocos: [
            .paragrafo("O VisseVinil não mantém em seus servidores uma cópia do nome de usuário, da foto de perfil ou dos dados da coleção armazenados localmente no dispositivo."),
            .paragrafo("Como esses dados são armazenados localmente, a desinstalação do VisseVinil remove os dados armazenados pelo aplicativo do dispositivo, de acordo com o funcionamento do sistema operacional."),
            .paragrafo("O usuário também pode alterar os dados de seu perfil diretamente no aplicativo."),
            .paragrafo("A localização utilizada pelo VisseVinil não é armazenada pelo aplicativo."),
            .paragrafo("Os dados enviados ao Discogs durante uma pesquisa são tratados pelo próprio Discogs de acordo com sua Política de Privacidade e suas políticas de retenção. O Discogs informa que mantém informações pessoais somente pelo período razoavelmente necessário para prestar seus serviços ou cumprir obrigações legais."),
            .paragrafo("O Discogs também disponibiliza um procedimento próprio para solicitações de exclusão de informações pessoais. Essas solicitações estão sujeitas às condições e exceções previstas em sua Política de Privacidade e nas leis aplicáveis."),
        ]),
        Secao(titulo: "8. Controle sobre suas informações", blocos: [
            .paragrafo("O usuário pode controlar as informações utilizadas pelo VisseVinil da seguinte forma:"),
            .lista([
                "**Nome de usuário:** pode ser alterado na edição do perfil;",
                "**Foto de perfil:** pode ser adicionada, substituída ou removida conforme as funcionalidades disponíveis no aplicativo;",
                "**Localização:** pode ser autorizada ou bloqueada nas configurações de privacidade do dispositivo;",
                "**Dados armazenados localmente:** podem ser removidos do dispositivo mediante a desinstalação do aplicativo;",
                "**Dados enviados ao Discogs:** são tratados pelo Discogs de acordo com sua própria Política de Privacidade e seus procedimentos de privacidade.",
            ]),
            .paragrafo("O Discogs informa que usuários podem solicitar acesso, correção, restrição, oposição ou exclusão de informações pessoais, conforme aplicável à sua situação e à legislação correspondente. As solicitações de exclusão podem ser realizadas por meio do procedimento disponibilizado pelo próprio Discogs."),
        ]),
        Secao(titulo: "9. Serviços de terceiros", blocos: [
            .paragrafo("O VisseVinil utiliza a API do Discogs como serviço de terceiros para realizar pesquisas e obter informações e imagens relacionadas a discos."),
            .paragrafo("O VisseVinil utiliza esse serviço exclusivamente para oferecer as funcionalidades descritas nesta Política de Privacidade."),
            .paragrafo("O tratamento de informações realizado pelo Discogs é regido pela Política de Privacidade do Discogs e pelos demais termos e políticas aplicáveis ao serviço."),
            .paragrafo("Os termos da API do Discogs estabelecem regras específicas para o uso de seu conteúdo, incluindo restrições aplicáveis a dados classificados como Restricted Data. O VisseVinil utiliza a API de acordo com esses termos."),
        ]),
        Secao(titulo: "10. Segurança", blocos: [
            .paragrafo("O VisseVinil adota medidas técnicas e organizacionais apropriadas para proteger as informações utilizadas pelo aplicativo contra acesso, alteração, divulgação ou uso não autorizado."),
            .paragrafo("Como os dados pessoais de perfil e os dados da coleção são armazenados localmente no dispositivo, sua proteção também depende das medidas de segurança aplicadas ao próprio dispositivo pelo usuário."),
            .paragrafo("O VisseVinil não mantém uma base de dados própria contendo os nomes, fotos de perfil ou dados pessoais de seus usuários."),
        ]),
        Secao(titulo: "11. Privacidade e dados fornecidos ao Discogs", blocos: [
            .paragrafo("O VisseVinil não solicita ao usuário informações pessoais para serem utilizadas pelo Discogs além das informações necessárias para realizar as pesquisas solicitadas."),
            .paragrafo("O nome de usuário e a foto de perfil do VisseVinil não são enviados ao Discogs."),
            .paragrafo("A localização utilizada pelo VisseVinil também não é enviada ao Discogs."),
            .paragrafo("Quando uma pesquisa é realizada, as informações necessárias para processá-la podem ser transmitidas ao Discogs, conforme descrito nesta Política de Privacidade."),
            .paragrafo("A Política de Privacidade do Discogs informa que o serviço pode processar informações como endereço IP, histórico de pesquisas e informações técnicas do dispositivo, além de estabelecer suas próprias regras de retenção, segurança, compartilhamento e exclusão de dados."),
        ]),
        Secao(titulo: "12. Direitos e solicitações relacionadas à privacidade", blocos: [
            .paragrafo("Caso o usuário tenha dúvidas sobre o tratamento de suas informações pelo VisseVinil ou queira entrar em contato sobre privacidade, poderá utilizar o seguinte endereço:"),
            .paragrafo("E-mail: [vissevinil@gmail.com](mailto:vissevinil@gmail.com)"),
            .paragrafo("Como o VisseVinil não mantém em seus servidores os dados de perfil e de coleção armazenados localmente, solicitações relacionadas a esses dados devem ser tratadas considerando que eles permanecem no dispositivo do próprio usuário."),
            .paragrafo("Quando a solicitação estiver relacionada a informações tratadas pelo Discogs por meio da API, o usuário poderá utilizar os mecanismos disponibilizados pelo próprio Discogs em sua Política de Privacidade."),
        ]),
        Secao(titulo: "13. Conteúdo fornecido pelo Discogs", blocos: [
            .paragrafo("O VisseVinil reconhece que determinados conteúdos apresentados pelo aplicativo são fornecidos por meio da API do Discogs e permanecem sujeitos aos termos e condições estabelecidos pelo Discogs."),
            .paragrafo("O VisseVinil não é afiliado, patrocinado ou endossado pelo Discogs."),
            .paragrafo("Data provided by Discogs."),
            .paragrafo("O VisseVinil seguirá as exigências de atribuição e demais condições estabelecidas nos Termos de Uso da API do Discogs para a utilização de seu conteúdo. Os termos do Discogs exigem que o aviso de não afiliação seja apresentado de forma proeminente e que o aviso “Data provided by Discogs.” seja apresentado junto aos dados utilizados, com link para a página correspondente do Discogs."),
        ]),
        Secao(titulo: "14. Alterações nesta Política de Privacidade", blocos: [
            .paragrafo("Esta Política de Privacidade poderá ser atualizada quando houver mudanças no funcionamento do VisseVinil, nas informações utilizadas pelo aplicativo ou na forma como essas informações são tratadas."),
            .paragrafo("Quando houver uma alteração, a data da última atualização será modificada no início desta Política."),
        ]),
        Secao(titulo: "15. Contato", blocos: [
            .paragrafo("Se você tiver dúvidas sobre esta Política de Privacidade ou sobre o tratamento de informações pelo VisseVinil, entre em contato conosco:"),
            .paragrafo("E-mail: [vissevinil@gmail.com](mailto:vissevinil@gmail.com)"),
        ]),
    ]
}
