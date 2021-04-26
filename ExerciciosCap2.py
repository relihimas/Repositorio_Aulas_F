# 1) Uma das funções mais procuradas por usuários de aplicativos de saúde é o de controle de
# calorias ingeridas em um dia. Por essa razão, você deve elaborar um algoritmo implementado
# em Python em que o usuário informe quantos alimentos consumiu naquele dia e depois possa
# informar o número de calorias de cada um dos alimentos.
# Como não estudamos listas neste capítulo, você não deve se preocupar em armazenar todas
# as calorias digitadas, mas deve exibir o total de calorias no final.

# usuário informe quantos alimentos consumiu naquele dia
qtealimentacao = int(input("Quantos alimentos você consumiu hoje? "))
# e depois possa informar o número de calorias de cada um dos alimentos
caloriastotal = 0

for i in range(1, qtealimentacao +1):
    caloriastotal += int(input(f"Informe a caloria do alimento nº {i}: "))

print("Você se alimentou {} vezes e consumiu: {} calorias".format(qtealimentacao, caloriastotal))


# 2) Muitos professores preferem adotar modelos diferentes de provas quando dão aulas para turmas muito grandes.
# Por essa razão, a escola de inglês JoWell Sant’ana, em que todas as turmas são compostas por 50 alunos, solicitou que
# você criasse um sistema capaz de atender ao seguinte requisito:
#
# O professor deve digitar primeiro as notas dos 25 alunos que têm número ímpar na chamada (1, 3, 5, ..., 47, 49);
# e depois, as notas dos 25 alunos que têm número par (2, 4, 6,..., 48, 50). O sistema deve calcular e exibir a média
# de cada uma das metades da sala e informar, ao final, qual delas teve a maior nota.
#
# Há ainda um pedido especial do mantenedor: que os professores não se confundam. Ao digitarem cada uma das notas,
# deve ser exibida uma mensagem no seguinte padrão:
#
# VOCÊ ESTÁ DIGITANDO AS NOTAS DOS ALUNOS PARES (ou ímpares, quando for o caso).
#
# POR FAVOR, INSIRA A NOTA DO ALUNO DE NÚMERO x.


print("Olá Professor!")
notaimpar = 0
notapar = 0

# O professor deve digitar primeiro as notas dos 25 alunos que têm número ímpar na chamada (1, 3, 5, ..., 47, 49);
for i in range(1, 51, 2):
    print("VOCÊ ESTÁ DIGITANDO AS NOTAS DOS ALUNOS ÍMPARES")
    notaimpar += float(input(f"POR FAVOR, INSIRA A NOTA DO ALUNO DE NÚMERO {i}: "))


# e depois, as notas dos 25 alunos que têm número par (2, 4, 6,..., 48, 50).
for i in range(2, 51, 2):
    print("VOCÊ ESTÁ DIGITANDO AS NOTAS DOS ALUNOS PARES")
    notapar += float(input(f"POR FAVOR, INSIRA A NOTA DO ALUNO DE NÚMERO {i}: "))

# O sistema deve calcular e exibir a média de cada uma das metades da sala e informar, ao final, qual delas teve a maior nota.
mediaimpar = notaimpar / 25
mediapar = notapar / 25

print("\nA média da metade da sala ímpar foi: {}".format(mediaimpar))
print("\nA média da metade da sala par foi: {}".format(mediapar))

if mediaimpar > mediapar:
    print("\nMetade da sala ìmpar obteve a maior média")
elif mediaimpar == mediapar:
    print("\nAmbas as turmas obtiveram a mesma média" )
else:
    print("\nMetade da sala par obteve a maior média")
    
    
# Sua tarefa é criar um script que abra esse arquivo, extraia seu conteúdo, exiba o nome e o gênero de cada personagem e,
# ao final, mostre a quantidade de personagens do gênero masculino, a quantidade de personagens do gênero feminino e a
# quantidade de personagens de gênero não indicado presentes nesse arquivo.

# importando o módulo json
import json

dict_nome = {}
masc = []
femi = []
nind = []

# script que abra esse arquivo e extraia o conteúdo
def starwars():
    with open("star_wars.json", "r", encoding="utf-8") as starwars:
        lista_swars = json.load(starwars)
        for dict in lista_swars:
            for chave, valor in dict.items():
                # extraia seu conteúdo, exiba o nome e o gênero de cada personagem
                print("Personagem: {}. Seu gênero: {}".format(dict.get("name"), dict.get("gender")))
                # mostre a quantidade de personagens do gênero masculino, a quantidade de personagens do gênero feminino e a quantidade de personagens de gênero não indicado presentes nesse arquivo
                if dict.get("gender") == 'male':
                    masc.append(dict.get("gender"))
                elif dict.get("gender") == 'female':
                    femi.append(dict.get("gender"))
                else:
                    nind.append(dict.get("gender"))
                break

    print("\nA quantidade de personagens é {}".format(len(lista_swars)))
    print("\nA quantidade de personagens do gênero masculino é: {}".format(len(masc)))
    print("\nA quantidade de personagens do gênero feminino é: {}".format(len(femi)))
    print("\nA quantidade de personagens do gênero 'não indicado' é: {}".format(len(nind)))

starwars()
