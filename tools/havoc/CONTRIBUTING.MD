# guia para contribuição

### puxando alterações para `dev`

- é preferível que novas alterações sejam enviadas para um novo branch e, em seguida, uma solicitação pull seja feita para mesclar esse novo branch de volta ao main/master
- passos:
    1. criar um novo branch local:
        * `git switch -c <new_branch_name>`
    2. confirmar a nova branch foi criada:
        * `git branch -a`
    3. confirmar a branch de upstream que será commitado e fazer um push:
        * `git push -set-upstream origin <new_branch_name>`
