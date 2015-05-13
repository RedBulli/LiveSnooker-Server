module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    name: { type: DataTypes.STRING, allowNull: false, unique: 'leaguePlayerName', validate: { len: [3,50] }},
    LeagueId: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: 'leaguePlayerName'
    }
  };
  var Player = Sequelize.define("Player", schema, {
      classMethods: {
        associate: function(models) {
          Player.belongsTo(models.User);
          Player.belongsTo(models.League, {foreignKey: 'LeagueId'});
        }
      }
    }
  )

  return Player;
};
