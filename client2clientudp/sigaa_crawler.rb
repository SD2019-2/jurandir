# -------------------------------- *
# Universidade Federal de Goiás    *
# Instituto de Informática         *
# Creation date:   11/14/19        *
# Last updated on: 11/22/19        *
# Author: Marcelo Cardoso Dias     *
# -------------------------------- */

# sigaa_crawler.rb

# REQUIREMENTS -------------------------------
require "nokogiri"
require "erb"
require "byebug"

# --------------------------------------------

# PROBLEM SOLVING FUNCTIONS ------------------
def login
	#log('REQUESTING LOGIN PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{login_url()}"
	]

	jsessionid = File.read("#{cookies_path()}").gsub(/[\s]/, ' ').match(/JSESSIONID ([^ ]+)/)[1]

	lt = @page.match(/name=\"lt\" value=\"([^\"]+)/)[1]

	execution = @page.match(/name=\"execution\" value=\"([^\"]+)/)[1]

	encoded_username = ERB::Util.url_encode(@username)

	encoded_password = ERB::Util.url_encode(@password)

	form_data = "username=#{encoded_username}&password=#{encoded_password}&lt=#{lt}&execution=#{execution}&_eventId=submit"

	#log('REQUESTING 1st AUTHENTICATION PAGE...')
	@page = %x[
		curl -s -v -c #{cookies_path()} -b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		-d "#{form_data}" \
		"#{authentication_url1(jsessionid)}" \
		2>&1
	]

	ticket = @page.match(/ticket=([^\r]+)/)[1]

	#log('REQUESTING 2nd AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url2(ticket)}"
	]

	x = File.read("#{cookies_path()}").gsub(/[\s]/, ' ')
	# log(x)
	log jsessionid = x.match(/JSESSIONID ([^ ]+\.undefined)/)[1]

	#log('REQUESTING 3rd AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url3(jsessionid)}"
	]

	#log('REQUESTING 4th AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url4(encoded_username)}"
	]

	#log('REQUESTING 5th AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url5()}"
	]

	#log('REQUESTING 6th AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -v -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url6()}" \
		2>&1
	]

	ticket = @page.match(/ticket=([^\r]+)/)[1]

	#log('REQUESTING 7th AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url7(ticket)}"
	]

	#log('REQUESTING 8th AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url8()}"
	]

	#log('REQUESTING 9th AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url9()}"
	]

	#log('REQUESTING 10th AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{authentication_url10()}"
	]

	#log('REQUESTING 11th AUTHENTICATION PAGE...')
	@page = %x[\
		curl -s -c #{cookies_path()} \
		-b #{cookies_path()} \
		-k --ciphers 'DEFAULT:!DH' \
		"#{student_page_url()}"
	]
end

def scan_classes_table
	page = Nokogiri::HTML(@page, nil, Encoding::UTF_8.to_s)

	page.css('.descricao').each do |td|
		class_id = td.to_s.match(/value=\"(\d+)/)[1]
		
		j_id = td.to_s.match(/(j_id\d+)/)[1]

		form_data = "form_acessarTurmaVirtual=form_acessarTurmaVirtual&idTurma=#{class_id}&javax.faces.ViewState=#{j_id}&form_acessarTurmaVirtual%3AturmaVirtual=form_acessarTurmaVirtual%3AturmaVirtual"
	
		#log('REQUESTING CLASS PAGE...')
		@page = %x[
			curl -s -c #{cookies_path()} -b #{cookies_path()} \
			-k --ciphers 'DEFAULT:!DH' \
			-d "#{form_data}" \
			"#{class_url()}"
		]

		param_name1 = @page.match(/\(\'(formMenu:j_id_jsp_\d+_\d+)/)[1].gsub(/:/, '%3A')

		param1 = nil

		aux = @page.match(/\'items\':\[\{\'onleave\':\'\',\'onenter\':\'\',\'id\':\'(formMenu:j_id_jsp_\d+_\d+)/)

		if(aux == nil)
			param1 = @page.match(/\'items\':\[\{\'onleave\':\'\',\'id\':\'(formMenu:j_id_jsp_\d+_\d+)\',\'onenter\':\'\'}/)[1]
		else
			param1 = aux[1]
		end

		view_state = @page.match(/javax\.faces\.ViewState\" value=\"(j_id\d+)/)[1]

		param2 = @page.match(/\{'(formMenu:j_id_jsp_\d+_\d+)\':\'formMenu:j_id_jsp_\d+_\d+\'\},\'\'\)\;\}return false\">\s+<div class=\"itemMenu\">Participantes/)[1].gsub(/:/, '%3A')
		
		form_data = "formMenu=formMenu&#{param_name1}=#{param1}&javax.faces.ViewState=#{view_state}&#{param2}=#{param2}"

		#log('REQUESTING PARTICIPANTS PAGE...')
		@page = %x[
			curl -s -c #{cookies_path()} -b #{cookies_path()} \
			-k --ciphers 'DEFAULT:!DH' \
			-d "#{form_data}" \
			"#{participants_url()}"
		]

		page2 = Nokogiri::HTML(@page, nil, Encoding::UTF_8.to_s)

		page2.css('.participantes').css('.odd').each do |tr|
			aux = tr.css('td')[1].text.gsub(/\s{2,}/, ' ')

			if aux.match(/Departamento/)
				participant_type = 'professor'
				participant_name = aux.match(/^\s([^:]+)/)[1].gsub(/ Departamento/, '')
				participant_department = aux.match(/Departamento: ([^:]+)/)[1].gsub(/ Formação/, '')
				participant_degree = aux.match(/Formação: ([^:]+)/)[1].gsub(/ Usuário/, '')
				participant_username = aux.match(/Usuário: ([^\s]+)/)[1]
				participant_email = aux.match(/E-Mail: ([^\s]+)/)[1]
				
				@result[:participants] << {
					type: participant_type,
					name: participant_name,
					department: participant_department,
					degree: participant_degree,
					username: participant_username,
					email: participant_email
				}

				next
			end
						
			participant_type = 'aluno' 
			participant_name = aux.match(/^\s([^:]+)/)[1].gsub(/ Curso/, '')
			participant_course = aux.match(/Curso: ([^:]+)/)[1].gsub(/ Matrícula/, '')
			participant_registration = aux.match(/Matrícula: (\d+)/)[1]
			participant_username = aux.match(/Usuário: ([^\s]+)/)[1]
			participant_email = aux.match(/E-mail: ([^\s]+)/)[1]	

			@result[:participants] << {
				type: participant_type,
				name: participant_name,
				course: participant_course,
				registration: participant_registration,
				username: participant_username,
				email: participant_email
			}
			
			if tr.css('td')[4] != nil
				aux = tr.css('td')[4].text.gsub(/\s{2,}/, ' ')

				participant_type = 'aluno' 
				participant_name = aux.match(/^\s([^:]+)/)[1].gsub(/ Curso/, '')
				participant_course = aux.match(/Curso: ([^:]+)/)[1].gsub(/ Matrícula/, '')
				participant_registration = aux.match(/Matrícula: (\d+)/)[1]
				participant_username = aux.match(/Usuário: ([^\s]+)/)[1]
				participant_email = aux.match(/E-mail: ([^\s]+)/)[1]		

				@result[:participants] << {
					type: participant_type,
					name: participant_name,
					course: participant_course,
					registration: participant_registration,
					username: participant_username,
					email: participant_email
				}
			end 
		end

		page2.css('.participantes').css('.even').each do |tr|
			aux = tr.css('td')[1].text.gsub(/\s{2,}/, ' ')
			
			participant_type = 'aluno' 
			participant_name = aux.match(/^\s([^:]+)/)[1].gsub(/ Curso/, '')
			participant_course = aux.match(/Curso: ([^:]+)/)[1].gsub(/ Matrícula/, '')
			participant_registration = aux.match(/Matrícula: (\d+)/)[1]
			participant_username = aux.match(/Usuário: ([^\s]+)/)[1]
			participant_email = aux.match(/E-mail: ([^\s]+)/)[1]

			@result[:participants] << {
				type: participant_type,
				name: participant_name,
				course: participant_course,
				registration: participant_registration,
				username: participant_username,
				email: participant_email
			}
			
			if tr.css('td')[4] != nil
				aux = tr.css('td')[4].text.gsub(/\s{2,}/, ' ')

				participant_type = 'aluno' 
				participant_name = aux.match(/^\s([^:]+)/)[1].gsub(/ Curso/, '')
				participant_course = aux.match(/Curso: ([^:]+)/)[1].gsub(/ Matrícula/, '')
				participant_registration = aux.match(/Matrícula: (\d+)/)[1]
				participant_username = aux.match(/Usuário: ([^\s]+)/)[1]
				participant_email = aux.match(/E-mail: ([^\s]+)/)[1]
				
				@result[:participants] << {
					type: participant_type,
					name: participant_name,
					course: participant_course,
					registration: participant_registration,
					username: participant_username,
					email: participant_email
				}
			end 
		end
	end
end

def remove_tmp_files
	cmd = "if test -f '#{cookies_path()}' ; then
		    rm #{cookies_path()}
		fi"

	system(cmd)
end

def create_contacts_dir
	cmd = "if ! test -d '#{contacts_path()}' ; then
		    mkdir contacts
		fi"

	system(cmd)
end

# --------------------------------------------

# JSON FUNCIONS ------------------------------
def result_json
	return result_json = {
		participants: []
	}
end

# --------------------------------------------

# URL FUNCTIONS ------------------------------
def base_url
	return 'https://sigaa.sistemas.ufg.br/sigaa/'
end

def login_url
	return 'https://ufgnet.ufg.br/cas/login?locale=pt_BR&service=https%3A%2F%2Fsigaa.sistemas.ufg.br%2Fsigaa%2FverTelaLogin.do'
end

def authentication_url1 jsessionid
	return "https://ufgnet.ufg.br/cas/login;jsessionid=#{jsessionid}?locale=pt_BR&service=https%3A%2F%2Fsigaa.sistemas.ufg.br%2Fsigaa%2FverTelaLogin.do"
end

def authentication_url2 ticket
	return base_url() + "verTelaLogin.do?ticket=#{ticket}"
end

def authentication_url3 jsessionid
	return base_url() + "verTelaLogin.do;jsessionid=#{jsessionid}"
end

def authentication_url4 encoded_username
	return base_url() + "logar.do?dispatch=logOn&user.login=#{encoded_username}&passaporte=true"
end

def authentication_url5
	return base_url() + 'paginaInicial.do'
end

def authentication_url6
	return 'https://ufgnet.ufg.br/cas/login?locale=pt_BR&service=https%3A%2F%2Fsigaa.sistemas.ufg.br%2Fsigaa%2FpaginaInicial.do'
end

def authentication_url7 ticket
	return base_url() + "paginaInicial.do?ticket=#{ticket}"
end

def authentication_url8
	return base_url() + 'paginaInicial.do'
end

def authentication_url9
	return base_url()+ 'telasPosSelecaoVinculos.jsf'
end

def authentication_url10
	return base_url() + 'verPortalDiscente.do'
end

def student_page_url
	return base_url() + 'portais/discente/discente.jsf'
end

def class_url
	return base_url() + 'portais/discente/discente.jsf'
end

def participants_url
	return 'https://sigaa.sistemas.ufg.br/sigaa/ava/index.jsf'
end

# --------------------------------------------

# PATH FUNCTIONS -----------------------------
def current_path
	return %x|pwd|.gsub(/\n/, '') + '/'
end

def cookies_path
	return current_path() + 'cookies'
end

def contacts_path
	return current_path() + 'contacts/'
end

def result_json_path
	return current_path() + "contacts/#{@username}.json"
end

# --------------------------------------------

# SAVING FUNCTIONS ---------------------------
def save_result_json
	file = File.new(result_json_path(), 'w')
	file.puts @result
	file.close
end

# --------------------------------------------

# PRINTING FUNCTIONS -------------------------
def log msg
	puts '-' * 99
	puts msg
	puts '-' * 99
end

# --------------------------------------------

# MAIN ---------------------------------------
def main username, password
	create_contacts_dir()

	remove_tmp_files()

	@username = username

	@password = password

	@result = result_json()

	@page = nil

	login()

	scan_classes_table()

	@result[:participants].uniq!

	save_result_json()

	remove_tmp_files()

	puts @result
end

# --------------------------------------------
# --------------------------------------------

# TEST ---------------------------------------
username = ARGV.first

password = ARGV[1]

main(username, password)

# --------------------------------------------