# encoding: utf-8

class ConsumoController < ApplicationController
protect_from_forgery :except => :confirma_api

	layout "mobile"

	def index
		@clientes = Cliente.order('nome')
	end

	def detalhes
    @produtos_cols = [[], []]
		@cliente = Cliente.find(params[:id])
		@produtos = Produto.order('ordem').find_all{ |p| not (p.nome.include? "Recarga" or p.nome.include? "MOBILE") }
    @produtos.in_groups_of(2, false).each do |prods|
      @produtos_cols[0] << prods[0]
      @produtos_cols[1] << prods[1]
    end
    render :layout => 'bootstrap'
	end

	def novo_cliente
		@cliente = Cliente.new

    respond_to do |format|
      format.html
      format.json { render :json => @cliente }
    end
	end

	def create
    @cliente = Cliente.new(params[:cliente])

    respond_to do |format|
      if @cliente.save
        format.html { redirect_to consumo_path, :notice => 'Cliente criado com sucesso.' }
        format.json { render :json => @cliente, :status => :created, :location => @cliente }
      else
        format.html { render :action => "new" }
        format.json { render :json => @cliente.errors, :status => :unprocessable_entity }
      end
    end
  end

	def confirma
		cliente = Cliente.find(params[:id])
		consumo = params[:consumo]

		valor = 0

		consumo.each do |produto|
			produto_id = produto[0].to_i
			quantidade = produto[1].to_i

			next if quantidade == 0

			valor += Produto.find(produto_id).preco * quantidade
			Consumo.create!(:data => Date.today, :cliente_id => cliente.id, :produto_id => produto_id, :quantidade => quantidade)
		end

		cliente.saldo -= valor
		cliente.save!

		@cliente = cliente
		@valor = valor

    flash[:notice] = @cliente.nome+", seu saldo agora é: "+
      ActionController::Base.helpers.number_to_currency(@cliente.saldo)
    redirect_to consumo_path and return
	end

	def confirma_api
		cliente = Cliente.find(params[:id])
		consumo = params[:consumo]

		valor = 0

		consumo.each do |produto|
			produto_id = produto[0].to_i
			quantidade = produto[1].to_i

			next if quantidade == 0

			valor += Produto.find(produto_id).preco * quantidade
			Consumo.create!(:data => Date.today, :cliente_id => cliente.id, :produto_id => produto_id, :quantidade => quantidade)
		end

		cliente.saldo -= valor
		cliente.save!

		@cliente = cliente
		@valor = valor

        respond_to do |format|
          format.json {
            render :json => {
                :saldo => @cliente.saldo
              }
          }
        end
	end

end
