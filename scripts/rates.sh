#!/usr/bin/env bash

mc() {
  curl -s 'https://www.mastercard.com/marketingservices/public/mccom-services/currency-conversions/conversion-rates?exchange_date=0000-00-00&transaction_currency=HUF&cardholder_billing_currency=USD&bank_fee=0&transaction_amount=1000000'    -H 'sec-ch-ua: "Not;A=Brand";v="99", "Google Chrome";v="139", "Chromium";v="139"'    -H 'sec-ch-ua-mobile: ?0'    -H 'sec-ch-ua-platform: "macOS"'    -H 'sec-fetch-dest: document'    -H 'sec-fetch-mode: navigate'    -H 'sec-fetch-site: none'    -H 'sec-fetch-user: ?1'    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36' | jq -r .data.crdhldBillAmt | awk '{printf "%.3f\n", 1000000/$1}'
}

visa() {
curl -s "https://usa.visa.com/cmsapi/fx/rates?amount=1000000&fee=0&utcConvertedDate=$(date +%m/%d/%Y)&exchangedate=$(date +%m/%d/%Y)&fromCurr=USD&toCurr=HUF" -H "referer: https://usa.visa.com/support/consumer/travel-support/exchange-rate-calculator.html" | jq -r .reverseAmount  | xargs printf "%.3f\n"
}

wise() {
curl -s "https://api.transferwise.com/v1/rates?source=USD&target=HUF" -H "Authorization: Bearer $WISE_TOKEN" | jq -r '.[0].rate'
}

nap() {
  local wise val diff mark
  wise=$(wise)
  (
    echo "Source Rate Marker Spread"
    for src in mc visa wise; do
      val=$($src)
      mark=""
      diff=""

      if [ "$src" != "wise" ]; then
        diff=$(awk "BEGIN {print $val - $wise}")
        if awk "BEGIN {exit !($diff > 0.2)}"; then
          mark="☀️"
        elif awk "BEGIN {exit !($diff > 0 && $diff <= 0.2)}"; then
          mark="🌤️ "
        else
          mark="🌧️ "
        fi
      fi

      echo "$src $val $mark $diff"
    done
  ) | column -t
}
