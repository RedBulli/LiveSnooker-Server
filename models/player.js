module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    name: { type: DataTypes.STRING, allowNull: false }
  };
  var Player = Sequelize.define("Player", schema, {
      classMethods: {
        associate: function(models) {
          Player.belongsTo(models.User);
          Player.belongsTo(models.League);
        }
      }
    }
  )

  return Player;
};
