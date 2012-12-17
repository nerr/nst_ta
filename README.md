# About

Nerr Smart Trader - Triangular Arbitrage Trading System

It is a arbitrage script for Metatrader 4 base on Triangular Arbitrage strategy. The script can find triangular arbitrage ring auto.

## extern variable explain ##
<table>
	<tr>
		<td>name</td>
		<td>default</td>
		<td>desc</td>
	</tr>
	<tr>
		<td>EnableTrade</td>
		<td>true</td>
		<td>allow trade switch</td>
	</tr>
	<tr>
		<td>Superaddition</td>
		<td>false</td>
		<td>the the value is true and the thold value is big enough superaddition a ring again</td>
	</tr>
	<tr>
		<td>BaseLots</td>
		<td>0.5</td>
		<td>per order lots not the ring total lots</td>
	</tr>
	<tr>
		<td>MagicNumber</td>
		<td>99901</td>
		<td>use to tag the order opened by this EA</td>
	</tr>
	<tr>
		<td>LotsDigit</td>
		<td>2</td>
		<td>if your account allow min lots 0.1 only please set the value to 1, else do not change</td>
	</tr>
	<tr>
		<td>Currencies</td>
		<td>EUR|USD|GBP|CAD|AUD|CHF|JPY|NZD|</td>
		<td>script will use these currencies to find triangular arbitrage ring</td>
	</tr>
</table>


# License

	Copyright (c) 2012 Nerrsoft.com

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.