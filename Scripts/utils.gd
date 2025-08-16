extends Node


# A bunch of functions for matching string patterns
func is_pattern(text:String, pattern: String) -> String:
	var regex = RegEx.new()
	regex.compile(pattern)
	var result = regex.search(text)
	if result:
		if result.get_string().length() == text.length():
			return result.get_string()
		else:
			return ""
	else:
		return ""
	
func is_bracket_or_sign_pattern(text: String) -> String:
	var pattern = r"\[(\w+)\](\?|\!)?"
	return is_pattern(text, pattern)
	
func is_word_or_sign_pattern(text: String) -> String:
	var pattern = r"(\w+)(\?|\!)?"
	return is_pattern(text, pattern)
	
func is_last_char_sign(text: String) -> String:
	var c = text[text.length()-1]
	if c == "!" or c == "?": # add more signs here if necessary
		return c
	else:
		return ""
	
func get_bracket_cmd(text:String) -> String:
	var regex = RegEx.new()
	var pattern =  r"\[(\w+)\]"
	regex.compile(pattern)
	var matches = regex.search_all(text)
	if matches.size() > 0:
		return matches[0].get_string(1)
	else:
		return ""

func is_sentence_pattern(text: String) -> String:
	var pattern = r"^\w+( \w+)*"
	return is_pattern(text, pattern)


func parse_console_command(text: String) -> Dictionary:
	# Text processing logic. In the end the command is stored in cmd, and sign in sign.
	# Sentence is stored if found in sentenceStr
	var bracketsignStr = is_bracket_or_sign_pattern(text)
	var wordsignStr = is_word_or_sign_pattern(text)
	var sentenceStr = is_sentence_pattern(text)
	var cmd = ""
	var mark = ""
	
	if bracketsignStr != "":
		cmd = get_bracket_cmd(bracketsignStr)
		mark = is_last_char_sign(bracketsignStr)
		
	if wordsignStr != "":
		mark = is_last_char_sign(wordsignStr)
		if mark == "":
			cmd = wordsignStr
		else:
			cmd = wordsignStr.substr(0, wordsignStr.length()-1)

	return {"cmd": cmd, "mark": mark}
