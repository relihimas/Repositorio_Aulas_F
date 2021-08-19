from pymongo import MongoClient

"""CHAVES DO BANCO DE DADOS"""
client = MongoClient('localhost', 27017)
banco = client.cinema
album = banco.filmes

""" INSERINDO UM DOCUMENTO"""
filme_title = input(str("Insira o nome do filme: "))
filme_released = input(int("Insira o ano de lançamento: "))
filme_tagline = input(str("Insira a tagline: "))
filme_music = input(str("Insira a musica tema: "))

filme = {
            "title": filme_title,
            "released": filme_released,
            "tagline": filme_tagline,
            "music": filme_music
}

filme_insert = album.insert_one(filme).inserted_id

print("Documento inserido!")

"""BUSCANDO UM DOCUMENTO"""
retorno = album.find_one({"title": ""})
print(retorno)

"""ATULIZANDO UM DOCUMENTO"""
album.update_one({'title': ''}, {'$set': {'title': ''}})
print('Documento atualizado!')
