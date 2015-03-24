[![Gem Version](https://badge.fury.io/rb/payanyway.svg)](http://badge.fury.io/rb/payanyway)
[![Build Status](https://travis-ci.org/ssnikolay/payanyway.svg?branch=master)](https://travis-ci.org/ssnikolay/payanyway)
[![Code Climate](https://codeclimate.com/github/ssnikolay/payanyway.svg)](https://codeclimate.com/github/ssnikolay/payanyway)
[![Test Coverage](https://codeclimate.com/github/ssnikolay/payanyway/badges/coverage.svg)](https://codeclimate.com/github/ssnikolay/payanyway)

# Payanyway

Этот gem предназначен для быстрой интеграции платежного шлюза [payanyway](http://payanyway.ru) в ваше ruby приложение.

При возникновении вопросов следует ознакомиться с [документацией к шлюзу](http://moneta.ru/doc/MONETA.Assistant.ru.pdf).

- [Установка](#installation)
- [Подключение](#setup)
- [Использование](#usage)
    - [Запрос на оплату](#payment_url)
    - [Специальные URL'ы](#special_urls)
        - [Check URL](#check_url)
        - [Return URL и InProgress URL](#return_url)
    - [Расшифровка параметров](#params)
        - [Параметры, отвечающие за выбор платежной системы](#payment_ids)

##<a name="installation"></a> Установка

Добавьте эти строки в Gemfile вашего приложения:

```ruby
gem 'payanyway'
```

И выполните:

    $ bundle

Или установите напрямую:

    $ gem install payanyway

##<a name="setup"></a> Подключение

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
    # вызывается при отправке шлюзом пользователя на Success URL.
    #
    # ВНИМАНИЕ: является незащищенным действием!
    # Для выполнения действий после успешной оплаты используйте pay_implementation
  end
  
  def pay_implementation(params)
    # вызывается при оповещении магазина об 
    # успешной оплате пользователем заказа. (Pay URL)
    #
    # params[ KEY ], где KEY ∈ [ :moneta_id, :order_id, :operation_id,
    # :amount, :currency, :subscriber_id, :test_mode, :user, :corraccount,
    # :custom1, :custom2, :custom3 ]
  end
  
  def fail_implementation(order_id)
    # вызывается при отправке шлюзом пользователя на Fail URL.
  end
end
```

Создайте конфигурационный файл: `config/payanyway.yml`

```yml
development: &config
    moneta_id: YOUR_MONETA_ID
    currency: RUB
    payment_url: https://demo.moneta.ru/assistant.htm
    test_mode: 1
    token: secret_token
production: <<: *config
    payment_url: https://moneta.ru/assistant.htm
    test_mode: 0
```
##<a name="usage"></a> Использование

###<a name="payment_url"></a> Запрос на оплату

Чтобы получить ссылку на платежный шлюз для оплаты заказа пользователем,
используйте `Payanyway::Gateway.payment_url(params, use_signature = true)`, где `params[ KEY ]` такой, что `KEY` ∈
`[:order_id, :amount, :test_mode, :description, :subscriber_id, :custom1, :custom2, :custom3, :locale, :payment_system_unit_id, :payment_system_limit_ids]`

Если в настройках счета в системе **moneta.ru** выставлен флаг «Можно переопределять настройки в URL», то можно так же передавать   
`[:success_url, :in_progress_url, :fail_url, :return_url]`.

Пример минимальной ссылки:

```ruby
class Order < ActiveRecord::Base; end

class OrdersController < ApplicationController
  def create
    order = Order.create(params[:order])
    redirect_to Payanyway::Gateway.payment_url(
      order_id: order.id,
      amount: order.total_amount,
      description: "Оплата заказа № #{ order.number } на сумму #{ order.total_amount }руб."
    )
  end
end
```

###<a name="special_urls"></a> Специальные URL'ы

Gem **payanyway** добавляет специальные роуты для обработки запросов от шлюза.

####<a name="check_url"></a> Check URL

```ruby
class PayanywayController
  ...
  def check_implementation(params)
    # Вызывается при обработке проверочных запросов (Check URL)
    # params[ KEY ], где KEY ∈ [ :moneta_id, :order_id, :operation_id,
    # :amount, :currency, :subscriber_id, :test_mode, :user, :corraccount,
    # :custom1, :custom2, :custom3, :payment_system_unit_id ]
    
    # ВНИМАНИЕ: при отправке корректного ответа со стороны магазина,
    #   необходимо вернуть в методе параметры для генерации статус-кода.
    #   { amount: AMOUNT, state: STATE, description: DESCRIPTION,
    #   attributes: ATTRIBUTES, logger: true\false }
  end
end
```

Пример метода:

```ruby
...
def check_implementation(params)
  order = Order.find(params[:order_id])
  {
    amount: order.total_amount,
    state: order.state_for_payanyway, # нужно реализовать
    attributes: { name: 'John Smith', email: 'js@gmail.com' }
  }
end
...
```

**Возвращаемые параметры:**

 Название                  | Описание
---------------------------|:-----------------------------------------------------------
`:amount`                  | Сумма заказа
`:state`                   | Состояние оплаты заказа. (см. [таблицу состояний](#states))
`:description`             | Описание состояния заказа. Задается в произвольной форме.
`:attributes`              | Необязательный элемент. Содержит хеш произвольных параметров, которые будут сохранены в операции.
`:logger`                  | Вывести XML ответ в log (`Rails.logger`)

<a name="states"></a>**Возможные состояния оплаты заказа:**

 Состояние               | Описание
-------------------------|:-----------------------------------------------------------
`:paid`                  | Заказ оплачен. Уведомление об оплате магазину доставлено.
`:in_progress`           | Заказ находится в обработке. Точный статус оплаты заказа определить невозможно. (например, если пользователя отправило на InProgress URL, но уведомления на Pay URL от шлюза еще не поступало)
`:unpaid`                | Заказ создан и готов к оплате. Уведомление об оплате магазину не доставлено.
`:canceled`              | Заказ не является актуальным в магазине (например, заказ отменен). 

####<a name="return_url"></a> Return URL и InProgress URL

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
    #   Если к моменту, когда пользователя надо вернуть в магазин оплата,
    #   по какой-либо причине не завершена, то его перекинет на InProgress,
    #   если он указан, если не указан, то на Success URL.
    #   Если операция уже успешно выполнилась, то сразу на Success.
    #   В случае с картами чаще всего получается так, что операция не успевает выполниться,
    #   поэтому InProgress будет использован с бОльшей вероятностью, чем Success URL.
  end
  ...
end
```

###<a name="params"></a> Расшифровка параметров, используемых в gem'e

 params[ KEY ], где KEY    | В документации           | Описание
---------------------------|:-------------------------|:-----------------------------------------
`:moneta_id`               | `MNT_ID`                 | Идентификатор магазина в системе MONETA.RU.
`:order_id`                | `MNT_TRANSACTION_ID`     | Внутренний идентификатор заказа, однозначно определяющий заказ в магазине.
`:operation_id`            | `MNT_OPERATION_ID`       | Номер операции в системе MONETA.RU.
`:amount`                  | `MNT_AMOUNT`             | Фактическая сумма, полученная на оплату заказа.
`:currency`                | `MNT_CURRENCY_CODE`      | ISO код валюты, в которой произведена оплата заказа в магазине.
`:test_mode`               | `MNT_TEST_MODE`          | Флаг оплаты в тестовом режиме (1 - да, 0 - нет).
`:description`             | `MNT_DESCRIPTION`        | Описание оплаты.
`:subscriber_id`           | `MNT_SUBSCRIBER_ID`      | Внутренний идентификатор пользователя в системе магазина.
`:corraccount`             | `MNT_CORRACCOUNT`        | Номер счета плательщика.
`:custom[1|2|3]`           | `MNT_CUSTOM1`            | Поля произвольных параметров. Будут возвращены магазину в параметрах отчета о проведенной оплате.
`:user`                    | `MNT_USER`               | Номер счета пользователя, если оплата производилась с пользовательского счета в системе «MONETA.RU».
`:locale`                  | `moneta.locale`          | (ru\|en) Язык пользовательского интерфейса.
`:success_url`             | `MNT_SUCCESS_URL`        | URL страницы магазина, куда должен попасть покупатель после успешно выполненных действий.
`:in_progress_url`         | `MNT_INPROGRESS_URL`     | URL страницы магазина, куда должен попасть покупатель после успешного запроса на авторизацию средств, до подтверждения списания и зачисления средств.
`:fail_url`                | `MNT_FAIL_URL`           | URL страницы магазина, куда должен попасть покупатель после отмененной или неуспешной оплаты.
`:return_url`              | `MNT_RETURN_URL`         | URL страницы магазина, куда должен вернуться покупатель при добровольном отказе от оплаты.
`:attributes`              | `MNT_ATTRIBUTES`         | Содержит произвольные параметры, которые будут сохранены в операции.

####<a name="payment_ids"></a> Параметры, отвечающие за выбор платежной системы:

params[ KEY ], где KEY     | В документации           | Описание
---------------------------|:-------------------------|:-----------------------------------------
`:payment_system_unit_id`  | `paymentSystem.unitId`   | Конкретная [платежная система](https://www.moneta.ru/viewPaymentMethods.htm)
`:payment_system_limit_ids`| `paymentSystem.limitIds` | Список (разделенный запятыми) идентификаторов платежных систем.


## Contributing

1. Fork it ( https://github.com/ssnikolay/payanyway/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
