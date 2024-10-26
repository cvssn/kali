<p align="center">
    <img style="max-width: 100%; width: 300px;" src="https://raw.githubusercontent.com/sigstore/community/main/artwork/cosign/horizontal/color/sigstore_cosign-horizontal-color.svg" alt="logo do cosign">
</p>

# cosign

assinando contêineres oci (e outros artefatos) usando [sigstore](https://sigstore.dev/)

[![Go Report Card](https://goreportcard.com/badge/github.com/sigstore/cosign)](https://goreportcard.com/report/github.com/sigstore/cosign)
[![e2e-tests](https://github.com/sigstore/cosign/actions/workflows/e2e-tests.yml/badge.svg)](https://github.com/sigstore/cosign/actions/workflows/e2e-tests.yml)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/5715/badge)](https://bestpractices.coreinfrastructure.org/projects/5715)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/sigstore/cosign/badge)](https://api.securityscorecards.dev/projects/github.com/sigstore/cosign)

o cosign pretende tornar as assinaturas em uma **infraestrutura invisível**.

cosign suporta:

* "assinatura sem chave" com a autoridade de certificação fulcio de bem público sigstore e log de transparência rekor (padrão)
* assinatura de hardware e kms
* assinatura com um par de chaves privadas/públicas criptografadas geradas por fiança
* assinatura, verificação e armazenamento de contêineres em um registro oci
* pki bring-your-own

## info

`cosign` é desenvolvido como parte do projeto [`sigstore`](https://sigstore.dev).
também é utilizado um [canal slack](https://sigstore.slack.com)
clique [aqui](https://join.slack.com/t/sigstore/shared_invite/zt-mhs55zh0-XmY3bcfWn4XEyMqUUutbUQ) para o link de convite.

## instalações

para instalações homebrew, arch, nix, github action e kubernetes, consulte a [documentação de instalação](https://docs.sigstore.dev/cosign/system_config/installation/).

para linux e binários macos veja os [assets de release do github](https://github.com/sigstore/cosign/releases/latest).

:rotating_light: se você estiver baixando versões de fiança de nosso intervalo gcs - consulte mais informações na [notícia de deprecação](https://blog.sigstore.dev/cosign-releases-bucket-deprecation/) de 31 de julho de 2023 :rotating_light:

## instalação de desenvolvedor

se você já possui o go v.122+, você pode configurar um ambiente de desenvolvimento:

```shell
$ git clone https://github.com/sigstore/cosign
$ cd cosign
$ go install ./cmd/cosign
$ $(go env GOPATH)/bin/cosign
```
