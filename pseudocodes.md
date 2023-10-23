
```
Algorithm MB with Loop Fusion
Input: mini-batch B  
for each trainer Ti in trainers T do in parallel   
    for each instance J in Ti.instances do   
        votes[i,j] ← Ti.classify(B[j])   
        k ← poisson(λ)  
        W_inst ← j ∗ k  
        Ti.train on instance(W inst)  
    end for  
    if change detected then   
        reset classifier    
    end if   
end for   
E.compile(votes)  
B.clear()   
```


```
Algoritmo Socket Random
    Variáveis
        lastMinuteUpdate = 0
        ips = 0

    Função passouUmMinuto(início, atual)
        elapsedSeconds = (atual - início) / 1000.0
        Escreva("Elapsed Seconds: " + elapsedSeconds)
        Retorne elapsedSeconds > 60

    Função oscilarInstanciasPorSegundo(limite, maxRate, início, atual)
        PERCENT_10 = 0.10
        PERCENT_50 = 0.50
        PERCENT_90 = 0.90

        Se passouUmMinuto(lastMinuteUpdate, atual)
            Escolha um número aleatório entre 0, 1 e 2 e atribua a 'choice'
            Se choice for igual a 0
                ips = maxRate * PERCENT_10
            Senão, se choice for igual a 1
                ips = maxRate * PERCENT_50
            Senão
                ips = maxRate * PERCENT_90
            Fim Se
            lastMinuteUpdate = atual
        Fim Se

        Escreva("Limit Per Second: " + ips)

        Gere um número aleatório entre 0 e ips e atribua a 'ipsToSend'
        Retorne ipsToSend

    Função Principal
        Inicia SocketChannel

        Se socketChannel não for nulo
            Enquanto i < limite e keepGoing
                ipb = oscilarInstanciasPorSegundo(limite, maxRate, startTime, TempoAtual)

                Se passouUmMinuto(TempoPassado, TempoAtual)
                    TempoPassado = ObtenhaTempoAtual()
                Fim Se

                Enquanto numInst < ipb e i < limite
                    EscrevaParaSocketChannel(socketChannel, buffer)
                Fim Enquanto

                Se (ObtenhaTempoAtual() - startingAll) / 1000F > 600
                    break
                Fim Se
            Fim Enquanto
        Fim Se
Fim Algoritmo

```