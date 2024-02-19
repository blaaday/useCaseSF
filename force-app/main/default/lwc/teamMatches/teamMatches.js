import { LightningElement, api, wire } from 'lwc';
import getMatchesByTeam from '@salesforce/apex/MatchController.getMatchesByTeam';

export default class TeamMatches extends LightningElement {
    @api recordId;
    matches;
    numberOfMatches;
    @wire(getMatchesByTeam, { teamId: '$recordId' })
    wiredMatches({ error, data }) {
        if (data) {
            this.numberOfMatches = data.length;
            this.matches = data.map(record => ({
                ...record,
                tournament: this.getTournamentUrl(record.Tournament__c),
                formattedMatchDate: this.formatDate(record.Match_Date__c)
            }));
            
        } else if (error) {
            // Handle error
            console.error('Error retrieving matches:', error);
        }
    }

    getTournamentUrl(tournamentId) {
        return '/' + tournamentId;
    }

    formatDate(dateString) {
        const options = { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' };
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', options);
    }

}