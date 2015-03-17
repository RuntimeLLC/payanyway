[![Build Status](https://travis-ci.org/ssnikolay/payanyway.svg?branch=master)](https://travis-ci.org/ssnikolay/payanyway)
# Payanyway

Этот gem предназначен для быстрой интеграции платежного шлюза [payanyway](http://payanyway.ru) в ваше ruby приложение.

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
        # успешной оплате пользователем заказа.
        #
        #  params[ KEY ], где KEY ∈ [ moneta_id, order_id,  operation_id, amount,
        #  currency, subscriber_id, test_mode, user, corraccount, custom1,
        #  custom2, custom3 ]
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
production: <<: *development
    payment_url: https://moneta.ru/assistant.htm
    test_mode: 0
```
## Использование

```ruby
class OrderController < AplicationController
    def create
        order = Order.create(params[:order])
        redirect_to Payanyway::Gateway.payment_url(
            order_id: order.id,
            amount: order.total_amount
        )
    end
end
```

### Расшифровка параметров

 params[ KEY ], где KEY    | Описание
--------------------------|:-----------------------------------------------------------
 `moneta_id`              | Идентификатор магазина в системе MONETA.RU.
 `order_id`               | Внутренний идентификатор заказа, однозначно определяющий заказ в магазине.
 `operation_id`           | Номер операции в системе MONETA.RU.
 `amount`                 | Фактическая сумма, полученная на оплату заказа.
 `currency`               | ISO код валюты, в которой произведена оплата заказа в магазине.
 `test_mode`              | Флаг оплаты в тестовом режиме (1 - да, 0 - нет).
 `user`                   | Номер счета пользователя, если оплата производилась с пользовательского счета в системе «MONETA.RU».
 `corraccount`            | Номер счета плательщика.
 `custom[i]`              | Параметры, переданные в запросе на оплату через MONETA.Assistant.

## Contributing

1. Fork it ( https://github.com/ssnikolay/payanyway/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
