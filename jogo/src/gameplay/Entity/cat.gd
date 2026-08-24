class_name Cat
extends RefCounted

enum Status {
	ATIVO,
	INATIVO
} 

# Contrato de criação:
# - cat_id é gerado e controlado pelo backend Java, nunca pelo cliente.
# - Um Cat "oficial" só deve existir a partir de from_dict(), reconstruindo
#   dados que já vieram validados do servidor (ex: após confirmar uma compra).
# - Chamar Cat.new(...) diretamente com um ID inventado no cliente pode gerar
#   dessincronia entre o estado local e o backend. Evitar fora de from_dict().

const NOME_MAX_CARACTERES := 20

var cat_id: String
var cat_type: String # checar se deve ser String ou outro tipo
var name: String:
	set(value):
		if value.length() > NOME_MAX_CARACTERES:
			push_error("Nome excede o limite de %d caracteres" % NOME_MAX_CARACTERES)
			return
		if value.strip_edges() == "":
			push_error("Nome não pode ser vazio")
			return
		name = value
var appearance_id: String
var status: Status #enum definido em Ativo ou Inativo (estado do gato)



func _init(id: String, type: String, cat_name: String, appearance: String):
	cat_id = id
	cat_type = type
	name = cat_name
	appearance_id = appearance
	status = Status.ATIVO

func to_dict() -> Dictionary:
	return {
		"id": cat_id,
		"type": cat_type,
		"name": name,
		"appearance_id": appearance_id,
		"status": Status.keys()[status]  # converte enum -> string legível, ex: "ATIVO"
	}
	
static func from_dict(data: Dictionary) -> Cat:
	if not data.has("id") or not data.has("type") or not data.has("name") or not data.has("appearance_id") or not data.has("status"):
		push_error("Dados de gato incompletos: " + str(data))
		return null
	var status_str: String = data["status"]
	if not Status.keys().has(status_str):
		push_error("Status desconhecido: " + status_str)
		return null
	var new_cat := Cat.new(data["id"], data["type"], data["name"], data["appearance_id"])
	new_cat.status = Status[status_str]
	return new_cat

func _to_string() -> String:
	return "Cat: {id=%s, type=%s, name=%s, appearance=%s, status=%s}" % [cat_id, 
	cat_type, name, appearance_id, status]
