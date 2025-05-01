class Admin::ExchangesController < ApplicationController
  before_action :set_exchange, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @exchanges = Exchange.all.order(:name)
  end

  def show
  end

  def new
    @exchange = Exchange.new
  end

  def edit
  end

  def create
    @exchange = Exchange.new(exchange_params)
    if @exchange.save
      redirect_to admin_exchanges_path, notice: 'Биржа успешно создана.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @exchange.update(exchange_params)
      redirect_to admin_exchanges_path, notice: 'Биржа успешно обновлена.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exchange.destroy
    redirect_to admin_exchanges_path, notice: 'Биржа удалена.'
  end

  private

  def set_exchange
    @exchange = Exchange.find(params[:id])
  end

  def exchange_params
    params.require(:exchange).permit(:name, :slug, :api_url, :status, :description, :price_key, :volume_key, :change_key, :trades_key, :symbol_key, :chart_url)
  end

  def authorize_admin!
    authorize :admin, :admin? # Теперь используем универсальную проверку админских прав
  end
end
