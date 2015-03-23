[![Build Status](https://travis-ci.org/ssnikolay/payanyway.svg?branch=master)](https://travis-ci.org/ssnikolay/payanyway)
[![Code Climate](https://codeclimate.com/github/ssnikolay/payanyway.svg)](https://codeclimate.com/github/ssnikolay/payanyway)
[![Test Coverage](https://codeclimate.com/github/ssnikolay/payanyway/badges/coverage.svg)](https://codeclimate.com/github/ssnikolay/payanyway)

# Payanyway

Этот gem предназначен для быстрой интеграции платежного шлюза [payanyway](http://payanyway.ru) в ваше ruby приложение.
При возникновенни вопросов следует ознакомиться с [http://moneta.ru/doc/MONETA.Assistant.ru.pdf](http://moneta.ru/doc/MONETA.Assistant.ru.pdf)
## Установка

Добавьте эти строки в Gemfile вашего приложения:

```ruby
gem 'payanyway'
```

И выполните:

    $ bundle

Или установки напрямую:

    $ gem install payanyway

## Подключение

Добавьте engine в `config/routes.rb`
```ruby
Rails.application.routes.draw do
  mount Payanyway::Engine => '/payanyway'
end
```

Создайте `app/controllers/payanyway_controller.rb` со следующим кодом:

```ruby
class PayanywayController
  def success_implementation(order_id)
    # вызывается при отправки шлюзом пользователя на Success URL.
    #
    # ВНИМАНИЕ: является незащищенным действием!
    # Для выполнения действий после успешной оплаты используйте pay_implementation
  end
  
  def pay_implementation(params)
    # вызывается при оповещении магазина об 
    # успешной оплате пользователем заказа. (Pay URL)
    #
    #  params[ KEY ], где KEY ∈ [ :moneta_id, :order_id, :operation_id,
    #  :amount, :currency, :subscriber_id, :test_mode, :user, :corraccount,
    #  :custom1, :custom2, :custom3 ]
  end
  
  def fail_implementation(order_id)
    # вызывается при отправки шлюзом пользователя на Fail URL.
  end
end
```

Создайте конфигурационный файл: `config/payanyway.yml`

```yml
development: &config
    moneta_id: YOUR_MOTETA_ID
    currency: RUB
    payment_url: https://demo.moneta.ru/assistant.htm
    test_mode: 1
    token: secret_token
production: <<: *config
    payment_url: https://moneta.ru/assistant.htm
    test_mode: 0
```
## Использование

Что бы получить ссылку на платежный шлюз для оплаты заказа пользвателем,
используйте `Payanyway::Gateway.payment_url(params, use_signature = true)`, где `params[ KEY ]` такой, что `KEY` ∈
`[:order_id, :amount, :test_mode, :description, :subscriber_id, :custom1, :custom2, :custom3, :locale, :payment_system_unit_id, :payment_system_limit_ids]`

Если в настройках счета в системе **moneta.ru** выставлен флаг «Можно переопределять настройки в URL», то можно так же передавать   
`[:success_url, :in_progress_url, :fail_url, :return_url]`.

Пример:
```ruby
class Order < ActiveRecord::Base; end

class OrdersController < AplicationController
  def create
    order = Order.create(params[:order])
    redirect_to Payanyway::Gateway.payment_url(
      order_id: order.id,
      amount: order.total_amount,
      locale: 'ru',
      description: "Оплата заказа № #{ order.number } на сумму #{ order.total_amount }руб."
    )
  end
end
```
### Специальные URL'ы
Gem **payanyway** добовляет специальные роуты для обработки запросов от шлюза.
#### Return URL и InProgress URL

```ruby
class PayanywayController
 ...
 def return_implementation(order_id)
    # Вызывается при добровольном отказе пользователем от оплаты (Return URL)
  end

  def in_progress_implementation(order_id)
    # Вызывается после успешного запроса на авторизацию средств,
    # до подтверждения списания и зачисления средств (InProgress URL)
    #
    # ВНИМАНИЕ: InProgress URL может быть использован в любом способе оплаты.
    # Если к моменту, когда пользователя надо вернуть в магазин оплата
    # по какой-либо причине не завершена, то его перекинет на InProgress,
    # если он указан, если не указан, то на Success URL.
    # Если операция уже успешно выполнилась, то сразу на Success.
    # В случае с картами чаще всего получается так, что операция не успевает выполниться,
    # поэтому InProgress будет использован с бОльшей вероятностью, чем Success URL.
  end
  ...
end
```

#### Check URL

```ruby
class PayanywayController
  ...
  def check_implementation(params)
    # Вызывается при обработке проверочных запросов (Check URL)
    # params[ KEY ], где KEY ∈ [ :moneta_id, :order_id, :operation_id,
    # :amount, :currency, :subscriber_id, :test_mode, :user, :corraccount,
    # :custom1, :custom2, :custom3, :payment_system_unit_id ]
    
    # ВНИМАНИЕ: при отправки корректного ответа со стороны магазина, необходимо вернуть в методе параметры, для генерации статус-кода.
    # { amount: AMOUNT, state: STATE, description: DESCRIPTION, attributes: ATTRIBUTES, logger: true\false }
  end
end
```

Пример метода:

```ruby
  def check_implementation(params)
    order = Order.find(params[:order_id])
    {
      amount: order.total_amount,
      state: order.state_for_payanyway, # нужно реализовать
      attributes: { name: John Smith, email: js@gmail.com }
    }
  end
```

**Возвращаемые параметры:**

 Название                  | Описание
---------------------------|:-----------------------------------------------------------
`:amount`                  | Сумма заказа
`:state`                   | Состояние заказа.
`:description`             | Описание состояния заказа. Задается в произвольной форме.
`:attributes`              | Необязательный элемент. Содержит хеш произвольных параметры, которые будут сохранены в операции.
`:logger`                  | Вывести XML ответ в log (Rails.logger)

### Расшифровка параметров используемых в gem'e

 params[ KEY ], где KEY    | Описание
---------------------------|:-----------------------------------------------------------
`:moneta_id`               | Идентификатор магазина в системе MONETA.RU.
`:order_id`                | Внутренний идентификатор заказа, однозначно определяющий заказ в магазине.
`:operation_id`            | Номер операции в системе MONETA.RU.
`:amount`                  | Фактическая сумма, полученная на оплату заказа.
`:currency`                | ISO код валюты, в которой произведена оплата заказа в магазине.
`:test_mode`               | Флаг оплаты в тестовом режиме (1 - да, 0 - нет).
`:description`             | Описание оплаты.
`:subscriber_id`           | Внутренний идентификатор пользователя в системе магазина.
`:corraccount`             | Номер счета плательщика.
`:custom[1|2|3]`           | Поля произвольных параметров. Будут возращены магазину в параметрах отчета о проведенной оплате.
`:user`                    | Номер счета пользователя, если оплата производилась с пользовательского счета в системе «MONETA.RU».MONETA.Assistant.
`:locale`                  | (ru\|en) Язык пользовательского интерфейса.
`:payment_system_unit_id`  | Предварительный выбор платежной системы. (https://www.moneta.ru/viewPaymentMethods.htm)
`:payment_system_limit_ids`| Список (разделенный запятыми) идентификаторов платежных систем, которые необходимо показывать пользователю.
`:success_url`             | URL страницы магазина, куда должен попасть покупатель после успешно выполненных действий.
`:in_progress_url`         | URL страницы магазина, куда должен попасть покупатель после успешного запроса на авторизацию средств, до подтверждения списания и зачисления средств.
`:fail_url`                | URL страницы магазина, куда должен попасть покупатель после отмененной или неуспешной оплаты.
`:return_url`              | URL страницы магазина, куда должен вернуться покупатель при добровольном отказе от оплаты.


## Contributing

1. Fork it ( https://github.com/ssnikolay/payanyway/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
