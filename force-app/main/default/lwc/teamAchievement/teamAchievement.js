import { LightningElement, api, wire } from 'lwc';
import getTeamAchievements from '@salesforce/apex/MatchController.getTeamAchievements';

export default class TeamAchievement extends LightningElement {
    @api recordId;
    teamAchievements;
    numberOfAchievements;
    @wire(getTeamAchievements, { teamId: '$recordId' })
    wiredMatches({ error, data }) {
        if (data) {
            this.numberOfAchievements = data.length;
            this.teamAchievements = data.map(record => ({
                ...record,
                tournament: this.getTournamentUrl(record.Tournament__c),
            }));
            
        } else if (error) {
            // Handle error
            console.error('Error retrieving matches:', error);
        }
    }

    getTournamentUrl(tournamentId) {
        return '/' + tournamentId;
    }
}