# Description of project "Business performance analysis of Procrastinate Pro+ app"

## Data
Data description
The file `visits_info_short.csv` stores the server log with information about site visits, `orders_info_short.csv` — information about purchases, and `costs_info_short.csv` — information about advertising expenses.

`visits_info_short.csv`:
* `User Id` — a unique user ID,
* `Region` — the user's country,
* `Device` — user's device type,
* `Channel` — ID of the transition source,
* `Session Start` — date and time of the session start,
* `Session End` — date and time of the end of the session.

`orders_info_short.csv`:
* `User Id` — unique user ID,
* `Event Dt` — date and time of purchase,
* `Revenue` — the amount of the order.

`costs_info_short.csv`:
* `Channel` — the identifier of the advertising source,
* `Dt` — date of the advertising campaign,
* `Costs` — expenses for this campaign.

## Aim and tasks of the project
Despite huge investments in advertising the Procrastinate Pro+ entertainment application, the company has been suffering losses for the past few months.

**The aim is to identify the causes of inefficiency, the solution of which will help the company to grow.** 

Tasks:

* where users come from and what devices they use,
* how much does it cost to attract users from various advertising channels;
* how much money does each client bring in,
* when the cost of attracting a client pays off,
* what factors prevent attracting customers.

## Used libraries
*pandas*, *numpy*, *matplotlib*, *seaborn*