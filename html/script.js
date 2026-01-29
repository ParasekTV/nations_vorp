let currentData = null;

// Event Listener für NUI Nachrichten
window.addEventListener('message', function(event) {
    const data = event.data;

    console.log('[NUI] RAW EVENT DATA:', JSON.stringify(data, null, 2));

    if (data.action === 'openMenu') {
        console.log('[NUI] Action is openMenu, data.data:', data.data);
        console.log('[NUI] data.data.isMayor:', data.data.isMayor);
        console.log('[NUI] Type of isMayor:', typeof data.data.isMayor);
        openMenu(data.data);
    } else if (data.action === 'closeMenu') {
        console.log('[NUI] Action is closeMenu - hiding container');
        document.getElementById('container').classList.add('hidden');
    }
});

// ESC Taste zum Schließen
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

function openMenu(data) {
    currentData = data;
    
    // DETAILLIERTE DEBUG LOGS
    console.log('===========================================');
    console.log('[INFINITY NATIONS] Opening menu with data:');
    console.log('Town:', data.town.name);
    console.log('Is Citizen:', data.isCitizen);
    console.log('Is Mayor:', data.isMayor);
    console.log('Is Governor:', data.isGovernor);
    console.log('Mayor Name:', data.mayorName);
    console.log('Governor Name:', data.governorName);
    console.log('Full Data:', data);
    console.log('===========================================');
    
    // Setze Stadtname
    document.getElementById('townName').textContent = data.town.name;
    
    // Setze Nation
    document.getElementById('nationName').textContent = data.nation ? data.nation.name : 'Keine';
    
    // Setze Bürgermeister und Gouverneur Namen
    document.getElementById('mayorName').textContent = data.mayorName || 'Keiner';
    document.getElementById('governorName').textContent = data.governorName || 'Keiner';
    
    // Setze Bürger Anzahl
    document.getElementById('citizenCount').textContent = data.citizenCount + ' / ' + data.town.max_population;
    
    // Setze Banken
    document.getElementById('townBank').textContent = '$' + formatNumber(data.town.bank);
    document.getElementById('nationBank').textContent = data.nation ? '$' + formatNumber(data.nation.bank) : '$0';
    
    // Setze Steuern
    document.getElementById('bankTax').textContent = data.town.bank_tax + '%';
    document.getElementById('cityTax').textContent = '$' + formatNumber(data.town.city_tax);
    document.getElementById('entryFee').textContent = '$' + formatNumber(data.town.entry_fee);
    
    // Setze Belohnungen
    document.getElementById('rewardMoney').textContent = '$' + formatNumber(data.town.reward_money);
    document.getElementById('rewardXP').textContent = data.town.reward_xp + ' XP';
    
    // MOTD
    if (data.town.motd && data.town.motd !== '') {
        document.getElementById('motdText').textContent = data.town.motd;
        document.getElementById('motdSection').classList.remove('hidden');
    } else {
        document.getElementById('motdSection').classList.add('hidden');
    }
    
    // Zeige/Verstecke Aktionen
    if (data.isCitizen) {
        console.log('Showing citizen actions');
        document.getElementById('citizenActions').classList.remove('hidden');
        document.getElementById('nonCitizenActions').classList.add('hidden');
    } else {
        console.log('Showing non-citizen actions');
        document.getElementById('citizenActions').classList.add('hidden');
        document.getElementById('nonCitizenActions').classList.remove('hidden');
    }
    
    // Bürgermeister Kontrolle
    if (data.isMayor === true) {
        console.log('🏛️ SHOWING MAYOR CONTROLS!');
        document.getElementById('mayorActions').classList.remove('hidden');
        document.getElementById('mayorBankTax').value = data.town.bank_tax;
        document.getElementById('mayorCityTax').value = data.town.city_tax;
        document.getElementById('mayorEntryFee').value = data.town.entry_fee;
        document.getElementById('mayorRewardMoney').value = data.town.reward_money;
        document.getElementById('mayorRewardXP').value = data.town.reward_xp;
        document.getElementById('mayorMaxPop').value = data.town.max_population;
        document.getElementById('mayorMOTD').value = data.town.motd || '';
    } else {
        console.log('❌ HIDING MAYOR CONTROLS (isMayor:', data.isMayor, ')');
        document.getElementById('mayorActions').classList.add('hidden');
    }
    
    // Gouverneur Kontrolle
    if (data.isGovernor === true && data.nation) {
        console.log('👑 SHOWING GOVERNOR CONTROLS!');
        document.getElementById('governorActions').classList.remove('hidden');
        document.getElementById('governorTaxRate').value = data.nation.tax_rate || 5;
    } else {
        console.log('❌ HIDING GOVERNOR CONTROLS (isGovernor:', data.isGovernor, ', has nation:', !!data.nation, ')');
        document.getElementById('governorActions').classList.add('hidden');
    }
    
    // Zeige Menü
    document.getElementById('container').classList.remove('hidden');
}

function closeMenu() {
    document.getElementById('container').classList.add('hidden');
    $.post('https://infinity_nations_vorp/close', JSON.stringify({}));
}

function joinTown() {
    $.post('https://infinity_nations_vorp/joinTown', JSON.stringify({}));
}

function leaveTown() {
    $.post('https://infinity_nations_vorp/leaveTown', JSON.stringify({}));
}

function claimReward() {
    $.post('https://infinity_nations_vorp/claimReward', JSON.stringify({}));
}

function updateBankTax() {
    const value = document.getElementById('mayorBankTax').value;
    $.post('https://infinity_nations_vorp/updateTax', JSON.stringify({
        taxType: 'bank',
        value: parseInt(value)
    }));
}

function updateCityTax() {
    const value = document.getElementById('mayorCityTax').value;
    $.post('https://infinity_nations_vorp/updateTax', JSON.stringify({
        taxType: 'city',
        value: parseFloat(value)
    }));
}

function updateEntryFee() {
    const value = document.getElementById('mayorEntryFee').value;
    $.post('https://infinity_nations_vorp/updateTax', JSON.stringify({
        taxType: 'entry',
        value: parseFloat(value)
    }));
}

function updateRewardMoney() {
    const value = document.getElementById('mayorRewardMoney').value;
    $.post('https://infinity_nations_vorp/updateTax', JSON.stringify({
        taxType: 'reward_money',
        value: parseFloat(value)
    }));
}

function updateRewardXP() {
    const value = document.getElementById('mayorRewardXP').value;
    $.post('https://infinity_nations_vorp/updateTax', JSON.stringify({
        taxType: 'reward_xp',
        value: parseInt(value)
    }));
}

function updateMaxPopulation() {
    const value = document.getElementById('mayorMaxPop').value;
    $.post('https://infinity_nations_vorp/updateTax', JSON.stringify({
        taxType: 'max_population',
        value: parseInt(value)
    }));
}

function updateMOTD() {
    const value = document.getElementById('mayorMOTD').value;
    $.post('https://infinity_nations_vorp/updateTax', JSON.stringify({
        taxType: 'motd',
        value: value
    }));
}

function depositMoney() {
    const amount = document.getElementById('mayorBankAmount').value;
    if (!amount || amount <= 0) {
        alert('Bitte gib einen gültigen Betrag ein');
        return;
    }
    $.post('https://infinity_nations_vorp/depositMoney', JSON.stringify({
        amount: parseFloat(amount)
    }));
    document.getElementById('mayorBankAmount').value = '';
}

function withdrawMoney() {
    const amount = document.getElementById('mayorBankAmount').value;
    if (!amount || amount <= 0) {
        alert('Bitte gib einen gültigen Betrag ein');
        return;
    }
    $.post('https://infinity_nations_vorp/withdrawMoney', JSON.stringify({
        amount: parseFloat(amount)
    }));
    document.getElementById('mayorBankAmount').value = '';
}

function updateNationTax() {
    const value = document.getElementById('governorTaxRate').value;
    if (!currentData.nation) return;
    $.post('https://infinity_nations_vorp/updateNationTax', JSON.stringify({
        nationId: currentData.nation.id,
        taxRate: parseInt(value)
    }));
}

function governorWithdrawMoney() {
    const amount = document.getElementById('governorBankAmount').value;
    if (!amount || amount <= 0) {
        alert('Bitte gib einen gültigen Betrag ein');
        return;
    }
    if (!currentData.nation) return;
    $.post('https://infinity_nations_vorp/governorWithdrawMoney', JSON.stringify({
        nationId: currentData.nation.id,
        amount: parseFloat(amount)
    }));
    document.getElementById('governorBankAmount').value = '';
}

function governorDepositMoney() {
    const amount = document.getElementById('governorBankAmount').value;
    if (!amount || amount <= 0) {
        alert('Bitte gib einen gültigen Betrag ein');
        return;
    }
    if (!currentData.nation) return;
    $.post('https://infinity_nations_vorp/governorDepositMoney', JSON.stringify({
        nationId: currentData.nation.id,
        amount: parseFloat(amount)
    }));
    document.getElementById('governorBankAmount').value = '';
}

function formatNumber(num) {
    return Math.round(num).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// Debug für Entwicklung
if (window.location.protocol === 'file:') {
    console.log('Debug Modus aktiv');
    setTimeout(() => {
        openMenu({
            town: {
                name: 'Valentine',
                nation_id: 1,
                mayor_id: null,
                bank: 15000,
                bank_tax: 5,
                city_tax: 10,
                entry_fee: 50,
                max_population: 100,
                reward_money: 25,
                reward_xp: 10,
                motd: 'Willkommen in Valentine! Die beste Stadt im Westen.'
            },
            nation: {
                name: 'New Hanover',
                governor_id: null,
                bank: 50000
            },
            citizenCount: 25,
            isCitizen: false,
            isMayor: false
        });
    }, 1000);
}
