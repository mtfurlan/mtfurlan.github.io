---
layout: post
title:  "Exporting Amazon Data when order export doesn't work"
categories: amazon
---

A friend needed amazon order data for tax reasons.
The order export didn't work.
<!--excerpt-->

On each page of the order history I ran this
```
orderList = []; document.getElementsByClassName("a-box-group a-spacing-base order js-order-card").forEach((order) => { orderList.push({ date: order.getElementsByClassName("a-color-secondary value")[0].innerText, price: order.getElementsByClassName("a-color-secondary value")[1].innerText, name: order.getElementsByClassName("a-link-normal")[3].innerText }); }); console.log(JSON.stringify(orderList));
```
and copied the output to a file.

I edited the file to be a single array, and got a csv with
```
jq -r ' map([.date, .price, .name] | join(", ")) | join("\n")' amazon-2020.json  > amazon-2020.csv
```

