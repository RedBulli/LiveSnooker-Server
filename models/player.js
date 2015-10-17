module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: { primaryKey: true, type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4 },
    name: { type: DataTypes.STRING, allowNull: false, validate: { len: [3,50] }},
    LeagueId: { type: DataTypes.UUID, allowNull: false },
    deleted: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false }
  };
  var Player = Sequelize.define("Player", schema, {
      classMethods: {
        associate: function(models) {
          Player.belongsTo(models.League, {foreignKey: 'LeagueId', onDelete: "CASCADE" });
        }
      },
      indexes: [
        { unique: 'leaguePlayerName', fields: ['name', 'LeagueId'], where: { deleted: false } }
      ],
      defaultScope: {
        where: {
          deleted: false
        }
      }
    }
  )

  return Player;
};
