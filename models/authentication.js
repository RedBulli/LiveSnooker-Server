module.exports = function(Sequelize, DataTypes) {
  var schema = {
    vendorUserId: { type: DataTypes.STRING, allowNull: false, unique: 'vendorIndex' },
    vendor: { type: DataTypes.STRING, allowNull: false, unique: 'vendorIndex' }
  };
  var Authentication = Sequelize.define("Authentication", schema, {
      classMethods: {
        associate: function(models) {
          Authentication.belongsTo(models.User, { foreignKey: {allowNull: false}, onDelete: "RESTRICT" })
        }
      }
    }
  )

  return Authentication;
};
